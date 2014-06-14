git-get-branch() {
  git branch -a |sed -n 's,^\* ,,p'
}
