grep-e-expr()
{
	[ $# -gt 0 ] && exec <<<"$*"

	sed 's,[().*?|\\],\\&,g ; s,\[,\\[,g ; s,\],\\],g' | implode "|" | sed 's,.*,(&),'
}
