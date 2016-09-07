git-set-remote()
{
  ( IFS="
"
  while :; do
    case "$1" in
      -f | --force) FORCE=true; shift ;;
      *) break ;;
    esac
  done

  gsr-arg() {
   (unset DIR NAME REMOTE
    ARG="$*"
    case "$ARG" in
      *:\ *) DIR=${ARG%%": "*}; ARG=${ARG#"$DIR: "} ;;
    esac
    if [ -n "$DIR" -a -d "$DIR" ]; then
      eval "${PRECMD}cd \"\$DIR\""
    fi
    case "$ARG" in
      *\ * | *$IFS*) NAME="${ARG%%[ $IFS]*}"; REMOTE="${ARG#*[ $IFS]}" ;;
      *) NAME="$ARG";  shift ;;
    esac
      [ -n "$DIR" ] && echo "Setting git remote '$NAME' in '$DIR' to '$REMOTE'" 1>&2

     eval "${PRECMD}git remote rm \"\$NAME\"" #2>/dev/null
     true

     if [ -n "$REMOTE" ]; then
       eval "${PRECMD}git remote add \"\$NAME\" \"\$REMOTE\""
     fi
   )
     #   for NAME in $(git-get-remote | awkp ); do :; done

  }
  CMD='gsr-arg $R'
  CMD="$CMD; R=\$?; [ \"\$FORCE\" = true -o \"\$R\" = 0 ] || exit \$R"

  if [ $# -le 0 ]; then
    CMD='while read -r R; do '$CMD'; done'
  else
    CMD='while [ $# -gt 0 ]; do
      case "$1|$2|$3" in
        *": "*\|*": "*\|*": "*) R="$1"; S=1 ;;
        *": "*\|?*\|*": "*) R="$1 $2"; S=2 ;;
        *": "*\|?*\|?*)   R="$1 $2 $3"; S=3 ;;
        ?*\|?*\|*)   R="$1 $2"; S=2 ;;
        *\|*\|*)   R="$1"; S=2 ;;
      esac
      '$CMD'
      echo "Shifting by $S" 1>&2
      [ "$S" -gt "$#" ]  && S=$#
      shift ${S:-1}
      unset S
    done'
  fi
  eval "$CMD")
}
