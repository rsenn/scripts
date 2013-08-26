git-set-remote()
{
  (while [ $# -gt 0 ]; do
  
    case "$1" in
      *\ *) BRANCH=${1%%" "*} ;;
      *) BRANCH="$1"; REMOTE="$2"; shift ;;
    esac
     git remote rm "$BRANCH" >&/dev/null
     
     git remote add "$BRANCH" "$REMOTE"
 
#   for BRANCH in $(git-get-remote | awkp ); do :; done

  
    shift
  done)
}