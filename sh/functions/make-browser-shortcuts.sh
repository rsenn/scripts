list-mediapath ()  {  ( unset CMD ; while :; do case "$1" in 

-b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s) FILTER="${FILTER:+$FILTER | }filter-test $1" ; shift ;;
 -x | -debug | --debug) DEBUG=true ; shift ;;
 -m | --mixed | -M | --mode | -u | --unix | -w | --windows | -a | --absolute | -l | --long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1" ; shift ;;
 -*) OPTS="${OPTS:+$OPTS }$1" ; shift ;;
 --) shift ; break ;;
 *) break ;;
 esac ; done ; for ARG in "$@" ; do ARG=${ARG//" "/"\\ "} ; ARG=${ARG//"("/"\\("} ; ARG=${ARG//")"/"\\)"} ; CMD="${CMD:+$CMD; }set -- $MEDIAPATH/${ARG#/} ; IFS=\$'\\n'; ls -1 -d $OPTS -- \$* 2>/dev/null | grep -v '\\*'" ; done ; [ -n "$PATHTOOL_OPTS" ] && CMD="${PATHTOOL:+$PATHTOOL ${PATHTOOL_OPTS:--m}} \$($CMD)" ; [ -n "$FILTER" ] && CMD="($CMD) | $FILTER" ; [ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2 ; eval "$CMD" ) ; }
make-browser-shortcuts () 
{ 
  . bash_profile.bash
   QUICKLAUNCH="$USERPROFILE/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch"
   echo "cd \"$QUICKLAUNCH\""
    l=$(list-mediapath -m 'P*/*'{Firefox,Chrome,Opera,SeaMonkey,QupZilla,Chromium,SpeedyFox,Waterfox,PaleMoon,Palemoon,Safari,K*Meleon}'*Portable*/'|removesuffix /);
    for x in $l;
    do
        y=$(basename "$x")
        z=$(ls -d -- "$x"/*Portable*.exe |head -n1)
        [ -n "$z" ] &&       z=$(cygpath -a "$z")
 [ -n "$z" -a -f "$z" ] && 
        echo "mkshortcut -n \"${y##*/}\" \"$z\"";
    done
}

[ "$(basename "${0#-}")" = "make-browser-shortcuts.sh" ] && make-browser-shortcuts 2>/dev/null
