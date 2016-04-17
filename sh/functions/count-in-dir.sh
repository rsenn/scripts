count-in-dir()
{
  NL="
"
         (LIST="$1"; shift; for ARG; do
         N=$(${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "^${ARG%/}/." "$LIST" | wc -l)
         echo $N "$ARG"
 done)
}
