#!/bin/sh

LEVEL=3
DIR=${2-"."}
ARCHIVE=${1-"../${PWD##*/}-`date +%Y%m%d`.7z"}

bce()
{
    (IFS=" "; echo "$*" | (bc -l || echo "ERROR: Expression '$*'" 1>&2)) | sed -u '/\./ s,\.\?0*$,,'
}

bci()
{
    (IFS=" "; : echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | sed -u 's,\.[0-9]\+$,,'
}


case "$ARCHIVE" in
  *.7z) CMD='7z a -mx=$(( $LEVEL * 5 / 9 )) "$ARCHIVE" "$DIR"' ;;
  *.zip) CMD='zip -${LEVEL} -r "$ARCHIVE" "$DIR"' ;;
  *.rar) CMD='rar a -m$(($LEVEL * 5 / 9)) -r "$ARCHIVE" "$DIR"' ;;
  *.txz|*.tar.xz) CMD='tar -cvJf "$ARCHIVE" "$DIR"' ;;
  *.tgz|*.tar.gz) CMD='tar -cvzf "$ARCHIVE" "$DIR"' ;;
  *.tbz2|*.tbz|*.tar.bz2) CMD='tar -cvjf "$ARCHIVE" "$DIR"' ;;
esac

eval "(set -x; $CMD)" &&
echo "Created archive '$ARCHIVE'"
