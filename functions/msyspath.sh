msyspath()
{ 
  ( MODE=msys;
  while :; do
      case "$1" in 
          -w)
              MODE=win32;
              shift
          ;;
          -m)
              MODE=mixed;
              shift
          ;;
          *)
              break
          ;;
      esac;
  done;
  for ARG in "$@";
  do
      ( case "$MODE:$ARG" in 
          *:[A-Za-z]:[/\\]* | *:[/\\]?/*)

          ;;
          win32:* | mixed:*)
              ARG=$(mount | sed -n '1 { s, .*,,p }')"$ARG"
          ;;
      esac;
      case "$MODE:$ARG" in 
          mixed:/?/* | win32:/?/*)
              DRIVE=${ARG#/};
              DRIVE=${DRIVE%%/*};
              ARG="$DRIVE:${ARG#/$DRIVE}"
          ;;
          msys:?:*)
              DRIVE=${ARG%%:*};
              ARG="/$DRIVE${ARG#$DRIVE:}"
          ;;
      esac;
      IFS="/\\";
      set -- $ARG;
      case "$MODE:$ARG" in 
          mixed:* | msys:*)
              IFS="/";
              ARG="$*"
          ;;
          win32:*)
              IFS="\\";
              ARG="$*"
          ;;
      esac;
      echo "$ARG" );
  done )
}
msyspath()
{ 
  ( MODE=msys;
  while :; do
      case "$1" in 
          -w)
              MODE=win32;
              shift
          ;;
          -m)
              MODE=mixed;
              shift
          ;;
          *)
              break
          ;;
      esac;
  done;
  for ARG in "$@";
  do
      ( case "$MODE:$ARG" in 
          *:[A-Za-z]:[/\\]* | *:[/\\]?/*)

          ;;
          win32:* | mixed:*)
              ARG=$(mount | sed -n '1 { s, .*,,p }')"$ARG"
          ;;
      esac;
      case "$MODE:$ARG" in 
          mixed:/?/* | win32:/?/*)
              DRIVE=${ARG#/};
              DRIVE=${DRIVE%%/*};
              ARG="$DRIVE:${ARG#/$DRIVE}"
          ;;
          msys:?:*)
              DRIVE=${ARG%%:*};
              ARG="/$DRIVE${ARG#$DRIVE:}"
          ;;
      esac;
      IFS="/\\";
      set -- $ARG;
      case "$MODE:$ARG" in 
          mixed:* | msys:*)
              IFS="/";
              ARG="$*"
          ;;
          win32:*)
              IFS="\\";
              ARG="$*"
          ;;
      esac;
      echo "$ARG" );
  done )
}
