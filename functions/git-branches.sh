git-branches () 
{ 
 (EXPR='\, -> ,d ;; s,^remotes/,,'
  while :; do
    case "$1" in
      -l | --local) EXPR="\\,^remotes/,d ;; $EXPR"; shift ;;
      -r | --remote) EXPR="\\,^remotes/,!d ;; $EXPR"; shift ;;
      *) break ;;
    esac
  done
  EXPR="s,^. ,, ;; $EXPR"
  git branch -a | sed "$EXPR"
 )
}
