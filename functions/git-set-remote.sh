git-set-remote()
{
  ( IFS="
"
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
     eval "${PRECMD}git remote rm \"\$NAME\"" >&/dev/null
     eval "${PRECMD}git remote add \"\$NAME\" \"\$REMOTE\""
   )
     #   for NAME in $(git-get-remote | awkp ); do :; done

  }
  CMD='gsr-arg $R'
  if [ $# -le 0 ]; then
    CMD='while read -r R; do '$CMD' || exit $? ; done'
  else
    CMD='while [ $# -gt 0 ]; do 
      case "$1|$2|$3" in
        *": "*\|*": "*\|*": "*) R="$1"; S=1 ;;
        *": "*\|*\|*": "*) R="$1 $2"; S=2 ;;
        *": "*\|*\|*)   R="$1 $2 $3"; S=3 ;;
        *\|*\|*)   R="$1 $2"; S=2 ;;
      esac
      '$CMD' || exit $?
      echo "Shifting by $S" 1>&2
      shift ${S:-1}
    done'
  fi
  eval "$CMD")
}
