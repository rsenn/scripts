find-all() { 

  
  (: ${LOCATE=`cmd-path locate`}
  
   [ -z "$LOCATE" ] && LOCATE=locate32.sh  || LOCATE="$LOCATE
-i
-r"
   
for ARG; do $LOCATE "$ARG"; done ; find-media.sh "$@") |sort -u 
  
  }

findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}
