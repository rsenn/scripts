git-get-branch() {
  if [ $# -ge 1 -a "${GGBREC}" != 1 ]; then
    for BRDIR; do (cd "$BRDIR" && GGBREC=1 git-get-branch "$BRDIR") | addprefix "$BRDIR: "; done
  else
    git branch -a |${SED-sed} -n 's,^\* ,,p'
  fi
}
