#!/bin/sh
IFS="
"
find ${@-*} "(" \
  -iname "*.rar" -or -iname "*.zip" -or -iname "*.7z" \
  ")" -exec file "{}" ";" | {
  IFS=":"

  match()
  {
   (PATTERN="$1"
    shift
    case "$@" in
      $PATTERN) exit 0 ;;
      *) exit 1 ;;
    esac)  
  }

  while read FILE TYPE; do
    TYPE=${TYPE#" "}

    case $FILE in
      *.[Zz][Ii][Pp]) match "Zip archive *" "$TYPE" || echo "$FILE" ;;
      *.[Rr][Aa][Rr]) match "RAR archive *" "$TYPE" || echo "$FILE" ;;
      *.7[Zz]) match "7-zip archive *" "$TYPE" || echo "$FILE" ;;
    esac
  done
}
