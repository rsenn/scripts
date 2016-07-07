count-in-dir()
{
         (LIST="$1"; shift; for ARG; do
         N=$(${GREP-grep
-a
--line-buffered
--color=auto} "^${ARG%/}/." "$LIST" | wc -l)
         echo $N "$ARG"
 done)
}
