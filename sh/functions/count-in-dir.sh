count-in-dir()
{
         (LIST="$1"; shift; for ARG; do
         N=$(${GREP-grep} "^${ARG%/}/." "$LIST" | wc -l)
         echo $N "$ARG"
 done)
}
