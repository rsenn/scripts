git-get-branch() {
  git branch -a |${SED-sed} -n 's,^\* ,,p'
}
