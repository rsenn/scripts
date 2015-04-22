bpm() {
  id3v2  -l "$@"|sed -n "/^id3v2 tag info for / {
		:lp     
		N
		/\n[[:upper:][:digit:]]\+ ([^\n]*$/ {
			/\nTBPM[^\n]*$/! {
				s|\n[^\n]*$||
				b lp
			}
			s|TBPM (.*): ||g
			b ok
		}
		/:\s*$/! {
			s|\n| |g
			b lp
		}
		:ok     
		s|\n[^\n]*:\s*$||
		s|^id3v2 tag info for \([^\n]*\) *: *\n *|\1: |
		p
  }"
}

#bpm()
#{
#    ( unset NAME;
#    if [ $# -gt 1 ]; then
#        NAME=":";
#    fi;
#    for ARG in "$@";
#    do
#        BPM=` id3v2 -l "$ARG" |sed -n 's,TBPM[^:]*:\s*,,p' `;
#        echo "${NAME+$ARG: }${BPM%.*}";
#    done )
#}
