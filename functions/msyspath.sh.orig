msyspath()
{
 (case $MODE in
    win32|mixed) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
    *) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^\([A-Za-z0-9]\):|/\\1|" ;;
  esac
  case $MODE in
    win32) 
      SCRIPT="${SCRIPT:+$SCRIPT ;; }s|/|\\\\|g"
      ROOT=$(mount  |sed -n  's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      SCRIPT="${SCRIPT:+$SCRIPT ;; }/^.:/!  s|^|$ROOT|"

      
      ;;
    *) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^/A/|/a/|;;s|^/B/|/b/|;;s|^/C/|/c/|;;s|^/D/|/d/|;;s|^/E/|/e/|;;s|^/F/|/f/|;;s|^/G/|/g/|;;s|^/H/|/h/|;;s|^/I/|/i/|;;s|^/J/|/j/|;;s|^/K/|/k/|;;s|^/L/|/l/|;;s|^/M/|/m/|;;s|^/N/|/n/|;;s|^/O/|/o/|;;s|^/P/|/p/|;;s|^/Q/|/q/|;;s|^/R/|/r/|;;s|^/S/|/s/|;;s|^/T/|/t/|;;s|^/U/|/u/|;;s|^/V/|/v/|;;s|^/W/|/w/|;;s|^/X/|/x/|;;s|^/Y/|/y/|;;s|^/Z/|/z/|" ;; 
    win*)  SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^a:|A:|;;s|^b:|B:|;;s|^c:|C:|;;s|^d:|D:|;;s|^e:|E:|;;s|^f:|F:|;;s|^g:|G:|;;s|^h:|H:|;;s|^i:|I:|;;s|^j:|J:|;;s|^k:|K:|;;s|^l:|L:|;;s|^m:|M:|;;s|^n:|N:|;;s|^o:|O:|;;s|^p:|P:|;;s|^q:|Q:|;;s|^r:|R:|;;s|^s:|S:|;;s|^t:|T:|;;s|^u:|U:|;;s|^v:|V:|;;s|^w:|W:|;;s|^x:|X:|;;s|^y:|Y:|;;s|^z:|Z:|" ;;
    esac
  (#set -x; 
   sed -u "$SCRIPT" "$@")
   )
 
 
 
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
  CMD='_msyspath'
  if [ "$1" != "-" -a "$#" -gt 0 ]; then
    CMD="echo \"\$*\" |$CMD"
  fi
    eval "$CMD"
    exit $?)
  
#  for ARG in "$@";
#  do
#      ( case "$MODE:$ARG" in 
#          *:[A-Za-z]:[/\\]* | *:[/\\]?/*)
#
#          ;;
#          win32:* | mixed:*)
#              ARG=$(mount | sed -n '1 { s, .*,,p }')"$ARG"
#          ;;
#      esac;
#      case "$MODE:$ARG" in 
#          mixed:/?/* | win32:/?/*)
#              DRIVE=${ARG#/};
#              DRIVE=${DRIVE%%/*};
#              ARG="$DRIVE:${ARG#/$DRIVE}"
#          ;;
#          msys:?:*)
#              DRIVE=${ARG%%:*};
#              ARG="/$DRIVE${ARG#$DRIVE:}"
#          ;;
#      esac;
#      IFS="/\\";
#      set -- $ARG;
#      case "$MODE:$ARG" in 
#          mixed:* | msys:*)
#              IFS="/";
#              ARG="$*"
#          ;;
#          win32:*)
#              IFS="\\";
#              ARG="$*"
#          ;;
#      esac;
#      echo "$ARG" );
#  done )
}
msyspath()
#{ 
#  ( MODE=msys;
#  while :; do
#      case "$1" in 
#          -w)
#              MODE=win32;
#              shift
#          ;;
#          -m)
#              MODE=mixed;
#              shift
#          ;;
#          *)
#              break
#          ;;
#      esac;
#  done;
#  for ARG in "$@";
#  do
#      ( case "$MODE:$ARG" in 
#          *:[A-Za-z]:[/\\]* | *:[/\\]?/*)
#
#          ;;
#          win32:* | mixed:*)
#              ARG=$(mount | sed -n '1 { s, .*,,p }')"$ARG"
#          ;;
#      esac;
#      case "$MODE:$ARG" in 
#          mixed:/?/* | win32:/?/*)
#              DRIVE=${ARG#/};
#              DRIVE=${DRIVE%%/*};
#              ARG="$DRIVE:${ARG#/$DRIVE}"
#          ;;
#          msys:?:*)
#              DRIVE=${ARG%%:*};
#              ARG="/$DRIVE${ARG#$DRIVE:}"
#          ;;
#      esac;
#      IFS="/\\";
#      set -- $ARG;
#      case "$MODE:$ARG" in 
#          mixed:* | msys:*)
#              IFS="/";
#              ARG="$*"
#          ;;
#          win32:*)
#              IFS="\\";
#              ARG="$*"
#          ;;
#      esac;
#      echo "$ARG" );
#  done )
#}
#
multiline_list()
{ 
    local indent='  ' IFS="
";
    while [ "$1" != "${1#-}" ]; do
        case $1 in 
            -i)
                indent=$2 && shift 2
            ;;
            -i*)
                indent=${2#-i} && shift
            ;;
        esac;
    done;
    if test -z "$*" || test "$*" = -; then
        cat;
    else
        echo "$*";
    fi | while read item; do
        echo " \\";
        echo -n "$indent$item";
    done
}
