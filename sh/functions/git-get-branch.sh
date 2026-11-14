git-get-branch() {
  if [ $# -ge 1 -a "${GGBREC}" != 1 ]; then
    for BRDIR; do O=$(cd "$BRDIR" && GGBREC=1 git-get-branch "$BRDIR");  test -n "$O" || break; echo "$BRDIR: $O"; done
  else
    git branch -a |${SED-sed} -n 's,^\* ,,p'
  fi
}
