git-get-remote()
{

  ([ $# -lt 1 ] && set -- .
  CMD='REMOTE=`git remote -v 2>/dev/null | sed "s|\s\+| |g ;; s|\s*([^)]*)||" |uniq`;'
  [ $# -gt 1 ] && CMD=$CMD'echo "$DIR: $REMOTE"' || CMD=$CMD'echo "$REMOTE"'
  for DIR; do
					
					(cd "$DIR";	eval "$CMD")
		done)

}
