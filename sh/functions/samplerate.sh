samplerate()
{
  ( N=$#
  for ARG in "$@";
  do
		EXPR='/^Sampling rate/ { s,^[^:]*:\s*,,; p }'
    test $N -le 1 && P="" || P="$ARG:"

		HZ=$(mediainfo "$ARG" | sed -n "$EXPR")

		case "$HZ" in
			*KHz) HZ=$(echo "${HZ% KHz} * 1000" | bc -l| sed 's,\.0*$,,') ;;
		  *Hz) HZ=$(echo "${HZ% Hz}" | sed 's, ,,g') ;;
		esac	
		echo "$P$HZ" 
	done)
}
