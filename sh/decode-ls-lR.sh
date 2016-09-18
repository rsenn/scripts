#!/bin/bash
ME=`basename "$0" .sh`

decode_ls_lR()
{
 (IFS=" "
  N=9
usage() {
   echo "Usage: $ME [OPTIONS] <FILE>

   -h, --help  Show this help
   -n NUM      How many fields to skip
   -p PREFIX   Prefix to prepend
   -l, --list  Keep full list
" 1>&2
   exit 1
 }

  while [ "$1" ]; do
    case "$1" in
    -h | --help) usage ;;
      -n) N="$2" ; shift 2 ;;
      -n*) N="${1#-n}" ; shift ;;
      -p) PREFIX="${2%/}"; shift 2 ;;
      -p*) PREFIX="${1#-p}"; shift ;;
      -l | --list) LIST="true"; shift ;;
      *) break ;;
    esac
  done

  ARG="$*"

  while read -r LINE; do
    set -- $LINE
    case "$LINE" in
            "") continue ;;
      *:)
        DIR="${LINE%:}"
        #echo "New directory $DIR" 1>&2
        continue
        ;;
      "file "* | "dir "* | "link "*)
         TYPE="$1" DATE="$2" TIME="$3" SIZE="$4" UNIT="$5"
         shift 5
         FILE="$*"
         ;;
         *\ *\ *\ *\ *\ ???\ *\ [0-9][0-9][0-9][0-9]\ * | \
        *\ *\ *\ *\ *\ ???\ [0-9][0-9]\ [0-9][0-9][0-9][0-9]\ * )
         MODE="$1" LINKS="$2" USER="$3" GROUP="$4" SIZE="$5" MONTH="$6" DAY="$7" YEAR="$8" TIME=
         shift 8
         FILE="$*"
        ;;
        *\ *\ *\ *\ *\ ???\ [0-9][0-9]\ [0-9][0-9]:[0-9][0-9]\ *)
         MODE="$1" LINKS="$2" USER="$3" GROUP="$4" SIZE="$5" MONTH="$6" DAY="$7" YEAR= TIME="$8"
         shift 8
         FILE="$*"
        ;;
      *\ *\ *\ *\ *\ [0-9]*\ *)
         MODE="$1" LINKS="$2" USER="$3" GROUP="$4" SIZE="$5" TIME="$6"
         shift 6
         FILE="$*"
        ;;
    esac
    if  [ -n "$YEAR" -a -n "$MONTH" -a -n "$DAY" ]; then
     DATE="$YEAR $MONTH $DAY"
    fi

    case "$FILE" in
         *" -> "*) TARGET=${FILE#*" -> "}; FILE=${FILE%%" -> "*} ;;
       */) ;;
     *) case "$TYPE" in
          dir) FILE="$FILE/" ;;
        esac
   ;;
    esac
    P="${PREFIX:+$PREFIX/}${DIR:+$DIR/}$FILE"
	  if [ "$LIST" = true ]; then
	  printf "%-11s %-2s %-7s %-10s %6s ${DATE:+%6s }%6s %s\n" "$MODE" "$LINKS" "$USER" "$GROUP" "$SIZE" ${DATE:+"$DATE"} "$TIME"  "$P"
	  else
       echo "$P"
      fi
  done)
}

decode_ls_lR "$@"
