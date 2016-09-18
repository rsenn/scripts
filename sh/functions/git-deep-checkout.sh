git-deep-checkout() {
  (for BRANCH in $(git-branches -r "$@"); do
    git branch --track "${BRANCH##*/}" "$BRANCH"
   done)
}
