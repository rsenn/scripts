count-in-dir()
{
				 (LIST="$1"; shift; for ARG; do
				 N=$(grep "^${ARG%/}/." "$LIST" | wc -l)
				 echo $N "$ARG"
 done)
}
