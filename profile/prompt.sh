SYSTEM=`cygpath -am /`; SYSTEM=${SYSTEM##*/}
homepath() {
  case "$PWD" in
    $HOME*) echo "~${PWD#$HOME}" ;;
    *) cygpath -am "$PWD" ;;
  esac
}
chr2dec() { 
  echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"%d\" \${ascii}]" | tclsh
}
colors_from_hostname() {
  S=1; N=${#HOSTNAME}; for I in $(seq 1 $((N - 1)) ); do  S=$((S * $(chr2dec "${HOSTNAME:$I:1}") )); S=$((S + 3)); done; C1="38;5;$(( S % 224 + 16))"; S=$((S / 224));  C2="38;5;$((S % 224 + 16))    "; S=$((S / 224));  C3="38;5;$((S % 224 + 16))"
} 
case "$SYSTEM" in
  msys*) C1="1;35" C2="1;34" ;;
  cyg*) C1="0;32" C2="0;33" ;;
  *) C1="38;5;178" C2="38;5;131" 
    colors_from_hostname
    ;;
esac
PS1='\[\e[${C1}m\]'${SYSTEM:-$USER}'\[\e[0m\]@\[\e[${C2}m\]'${HOSTNAME%.*}'\[\e[0m\] \[\e[${C3}m\]$(homepath -a "$PWD")\[\e[0m\]
$ '
