#!/bin/sh

KEEP_GOING=no
IFS="
"

if type aunpack 2>/dev/null 1>/dev/null; then
  AUNPACK="aunpack"
fi
    
unset OPT
while [ "$#" -gt 0 ]; do
  case $1 in
    -k) KEEP_GOING=yes ;;
    -r|--recursive) RECURSIVE=yes ;;
    -[0-9A-Za-z]) OPT="${OPT+$OPT
}$1" ;;
    -p) PASSWORD="$2"; shift ;;
    -p*) PASSWORD="${1#-p}" ;;
    *) break ;;
  esac
  shift
done

case $RECURSIVE in
  yes) find ${@:-*} -type f -and "(" \
          -iname "*.rar" \
      -or -iname "*.zip" \
      -or -iname "*.7z" \
      -or -iname "*.tar*" \
      -or -iname "*.tgz" \
      -or -iname "*.tbz*" ")" ;;
  *) echo "$*" ;;
esac |
while read ARG; do
  DIR=`dirname "$ARG"` FILE=`basename "$ARG"`
  MASK="$FILE"
  case $FILE in
    *part[0-9]*.rar)
      MASK=`echo "$FILE" | ${SED-sed} \
        -e "s/part[0-9][0-9]/part\[0-9\]\[0-9\]/" \
        -e "s/part[0-9]/part\[0-9\]/"
      ` ;;
    *.rar)
      if [ -e "${FILE%.rar}.r01" ]; then
        MASK=`echo "$FILE" | ${SED-sed} \
          -e "s/\.rar\$/.r\[a0-9\]\[r0-9\]/" \
        ` 
      fi ;;
  esac

 (case $FILE:$PASSWORD in
   *.exe|*) AUNPACK= ;;
   *|"") ;;
   *|*) AUNPACK= OPT=${OPT:+$OPT }-ad ;;
  esac
  set -e && 
  cd "$DIR" &&
  if [ "$AUNPACK" ]; then
    $AUNPACK "$FILE"
  else  
    TYPE=`file -i "$FILE"` && 
    case $TYPE:${FILE##*.} in
      *:\ application/x-rar*:*) 
        yes A | unrar x -p"${PASSWORD:--}" $OPT "$FILE" 
      ;;
      *:\ application/x-zip*:* | *:\ application/zip*:*) yes A | unzip $OPT "$FILE" ;;
      *:\ application/octet-stream:7[Zz]) yes A | 7za x $OPT "$FILE" ;;
      *:\ application/octet-stream*:[Ee][Xx][Ee]) unzip -d "${FILE%.*}" "$FILE" ;;
      *) echo "Unknown archive type:" $TYPE 1>&2 && exit 1 ;;
    esac
  fi) && rm -vf $MASK || if [ "$KEEP_GOING" = yes ]; then
    exit $?
  fi
done
