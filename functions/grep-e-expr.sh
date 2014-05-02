grep-e-expr()
{ 
  implode "|" "$@"  |sed 's,[()],&,g ; s,\[,\\[,g ; s,\],\\],g ; s,[.*],\\&,g ; s,.*,(&),'
}
