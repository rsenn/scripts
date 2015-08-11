#!/bin/bash

decode_ls_lR()
{
 (IFS=" "
	N=9

	while [ "$1" ]; do
		case "$1" in
			-n) N="$2" ; shift 2 ;;
			-n*) N="${1#-n}" ; shift ;;
			-p) PREFIX="$2"; shift 2 ;;
			-p*) PREFIX="${1#-p}"; shift ;;
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
		    *\ *\ *\ *\ *\ ???\ [0-9][0-9]\ [0-9][0-9]:[0-9][0-9]\ *)
				 MODE="$1" LINKS="$2" USER="$3" GROUP="$4" SIZE="$5" MONTH="$6" DAY="$7" TIME="$8"
				 shift 8
				 FILE="$*"
				;;
			*\ *\ *\ *\ *\ [0-9]*\ *)
				 MODE="$1" LINKS="$2" USER="$3" GROUP="$4" SIZE="$5" UTIME="$6"
				 shift 6
				 FILE="$*"
				;;
		esac

		case "$FILE" in
				 *" -> "*) TARGET=${FILE#*" -> "}; FILE=${FILE%%" -> "*} ;;
	  	 */) ;;
		 *) case "$TYPE" in
					dir) FILE="$FILE/" ;;
				esac
	 ;;
		esac

			 echo "${PREFIX:+$PREFIX/}${DIR:+$DIR/}$FILE"
	done)
}

decode_ls_lR "$@"
