#!/bin/bash

count()
{
echo $#
}

match()
{
 (PATTERN="$1"
  shift
	for ARG; do
		case "$ARG" in
			$PATTERN) echo "$ARG" ;; 
		esac
	done)
}
var_dump ()
{
    ( for N in "$@";
    do
        N=${N%%=*};
        O=${O:+$O${var_s-${IFS%${IFS#?}}}}$N=`eval 'str_quote "${'$N'}"'`;
    done;
    echo "$O" )
}
str_quote ()
{
    case "$**" in
        *["$cr$lf$ht$vt"]*)
            echo "\$'`str_escape "$*"`'"
        ;;
        *"$squote"*)
            echo "\"`str_escape "$*"`\""
        ;;
        *)
            echo "'$*'"
        ;;
    esac
}
str_escape ()
{
    local s=$*;
    case $s in
        *[$cr$lf$ht$vt'']*)
            s=${s//'\'/'\\'};
'/'\r'};    s=${s//'
            s=${s//'
'/'\n'};
            s=${s//'    '/'\t'};
            s=${s//'
                    '/'\v'};
            s=${s//\'/'\047'};
            s=${s//''/'\001'};
            s=${s//''/'\200'}
        ;;
        *$sq*)
            s=${s//"\\"/'\\'};
            s=${s//"\""/'\"'};
            s=${s//"\$"/'\$'};
            s=${s//"\`"/'\`'}
        ;;
    esac;
    echo "$s"
}



output()
{
[ "$PLAYLIST" = true -o "$SHOW_FILES" = true ] && set -- $(match "*${1}*" $FILES)

   for NAME; do
	 if [ "$PLAYLIST" = true ]; then
      TITLE=`basename "${NAME%.*}" | ${SED-sed} "s|[^[:alnum:]]\+| |g" | ${SED-sed} "s|\sTvR\s\?||gi ;; s|\sXivD\s\?||gi ;; s|\sXviD\s\?||gi ;; s|\sdTV\s\?||gi ;; s|\sHDTV\s\?||gi ;; s|\sGerman$||"`
	    echo "#EXTINF:,${TITLE}"
			echo "${NAME}"
	 elif [ "$SHOW_FILES" = true ]; then
			echo "$NAME"
	else
					echo "$NAME"
		fi
		done
}
IFS="
"

while :; do
  case "$1" in
	  -f | --files) SHOW_FILES=true; shift ;;
	  -p | --playlist) PLAYLIST=true; shift ;;
		*) break ;;
  esac
done

FILES=$(find "${@-.}" -type f -size +20M)

echo "Found $(count $FILES) files." 1>&2


EPISODES=`echo "$FILES" |${SED-sed} -n 's,.*[Ss]\([0-9][0-9]\)[Ee]\([0-9][0-9]\).*,S\1E\2,p' |sort -u`

set -- $EPISODES

echo "EPISODES: $@" 1>&2

SEASON="${1%%E*}"
SEASON=${SEASON#S}; SEASON=$((SEASON + 0))

EPISODE="${1##*E}"; EPISODE=$((EPISODE + 0))

MISSING=""

for LIST; do
    S=${LIST%%E*}; S=${S#S}; S=${S#0}; S=$((S + 0))

  [ "$S" -gt "$SEASON" ] && SEASON="$S"

  E=${LIST##*E}; E=${E#0}; E=$((E + 0))

   var_s=' ' var_dump SEASON EPISODE S E 1>&2 

     output "$LIST"


  [ $((S)) -eq $((SEASON)) -a $((E)) -eq $((EPISODE)) ] || {
  
    [ $((EPISODE)) -gt $((E)) ] &&
      printf "S%02d E%02d is missing!\n" $((SEASON-1))  $EPISODE 1>&2 ||
          printf "S%02d E%02d is missing!\n" $((SEASON))  $EPISODE 1>&2
  }
  EPISODE=$((E+1))
done

