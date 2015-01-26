get-frags() {
  EXPR="'s/.*Average frag.*:\\s\\+\\([0-9]\\+\\)\\s\\+.*/\\1/p'"
  [ $# -gt 1 ] && EXPR="$EXPR | sed \"s|^|\$ARG: |\""
  eval "for ARG; do
    contig -a \"\$ARG\" | sed -n $EXPR
  done"
}
