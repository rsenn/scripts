git-diffstat() {
  [ $# -le 0 ] && set -- $(git log | grep ^commit | head | awk '{ print $2 }')
  for COMMIT; do
    SHOW=$(git show "$COMMIT")
    (
      IFS=$'\n'
      set -- $SHOW
      echo "${*:1:3}"
      echo
      echo "$SHOW" | diffstat
      echo
    )
  done
}
