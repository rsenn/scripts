
#!/bin/bash

LEVEL=3
: ${EXCLUDE="*.git* *~ *.stackdump"}

while :; do
  case "$1" in
    -[0-9]) LEVEL=${1#-}; shift ;;
    -t) TYPE=$2; shift 2 ;;
    -E) EXCLUDE="$2"; shift 2 ;; -E=*) EXCLUDE="${1#*=}"; shift ;;
    -e | --exclude) EXCLUDE="${EXCLUDE:+$EXCLUDE }$2"; shift 2 ;; -e=* | --exclude=*) EXCLUDE="${EXCLUDE:+$EXCLUDE }${1#*=}"; shift ;;
    *) break ;;
  esac
done

ARCHIVE=${1-"../${PWD##*/}-`date ${DIR:+-r "$DIR"} +%Y%m%d`.${TYPE:-7z}"}
DIR=${2-"."}

bce()
{
    (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | sed -u '/\./ s,\.\?0*$,,'
}

bci()
{
    (IFS=" "; : echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | sed -u 's,\.[0-9]\+$,,'
}

create-list()
{
 (OUTPUT=
  SWITCH="$1"
  shift
  for ARG; do
    OUTPUT="${OUTPUT:+$OUTPUT }${SWITCH}'$ARG'"
  done
  echo "$OUTPUT"
  )
}
dir-contents()
{
			case "$1" in 
							.) ls -a -1 --color=no  |grep -v -E '^(\.|\.\.)$' |sort -u ;;
			*) echo "$*" ;;
			esac
}

set -f
case "$ARCHIVE" in
  *.7z) CMD='${SEVENZIP:-7z} a -mx=$(( $LEVEL * 5 / 9 )) "$ARCHIVE" '$(create-list '-x!' $EXCLUDE)' "$DIR"' ;;
  *.zip) CMD='zip -${LEVEL} -r "$ARCHIVE" "$DIR" '$(create-list '-x ' $EXCLUDE)' ' ;;
  *.rar) CMD='rar a -m$(($LEVEL * 5 / 9)) -r '$(create-list '-x' $EXCLUDE)' "$ARCHIVE" "$DIR"' ;;
	*.txz|*.tar.xz) CMD='tar -cvJf "$ARCHIVE" '$(create-list '--exclude=' $EXCLUDE)' $(dir-contents "$DIR")' ;;
  *.tgz|*.tar.gz) CMD='tar -cvzf "$ARCHIVE" '$(create-list '--exclude=' $EXCLUDE)' $(dir-contents "$DIR")' ;;
  *.tbz2|*.tbz|*.tar.bz2) CMD='tar -cvjf "$ARCHIVE" '$(create-list '--exclude=' $EXCLUDE)' $(dir-contents "$DIR")' ;;
esac
CMD='rm -vf "$ARCHIVE";'$CMD
echo "CMD='$CMD'" 1>&2
eval "(set -x; $CMD)" &&
echo "Created archive '$ARCHIVE'"
