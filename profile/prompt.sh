#SYSTEM=`cygpath -am /`; SYSTEM=${SYSTEM##*/}

case `uname -o` in
  *Linux*) ;;
*MSYS*|*Msys*|*MSys*|*msys*) PATHTOOL="cygpath
-am" ;;
  *) ;;
esac
: ${PATHTOOL=realpath}

homepath() {
  case "$PWD" in
    $HOME*) echo "~${PWD#$HOME}" ;;
    *) $PATHTOOL "$PWD" ;;
  esac
}
chr2dec() { 
  echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"%d\" \${ascii}]" | tclsh
}
colors_from_hostname() {
  S=1; H=${HOSTNAME%%.*}; N=${#H}; for I in $(seq 0 $((N - 1)) ); do  S=$((S * $(chr2dec "${H:$I:1}") )); S=$((S ^ 15)); done; C1="$(( S % 224 + 16))"; S=$((S / 224));  C2="$((S % 224 + 16))"; S=$((S / 224));  C3="$((S % 224 + 16))"
  C1="38;5;${C1#-}"
  C2="38;5;${C2#-}"
  C3="38;5;${C3#-}"
} 
case "$SYSTEM" in
  msys*) C1="1;35" C2="1;34" ;;
  cyg*) C1="0;32" C2="0;33" ;;
  *) C1="38;5;178" C2="38;5;131" 
    colors_from_hostname
    ;;
esac
PS1='\[\e[${C1}m\]'${USER}'\[\e[0m\]@\[\e[${C2}m\]'${HOSTNAME%.*}'\[\e[0m\]:(\[\e[${C3}m\]$(homepath -a "$PWD")\[\e[0m\]) \$ '
