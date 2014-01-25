git-get-remote()
{

  ([ $# -lt 1 ] && set -- .
  [ $# -gt 1 ] && FILTER="sed \"s|^|\$DIR: |\"" || FILTER=
  CMD="REMOTE=\`git remote -v 2>/dev/null | sed \"s|\\s\\+| |g ;; s|\\s*([^)]*)||\" |uniq ${FILTER:+|$FILTER}\`;"
  CMD=$CMD'echo "$REMOTE"'
  for DIR; do
					
					(cd "$DIR";	eval "$CMD")
		done)

}
