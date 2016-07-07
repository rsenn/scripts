SYSTEM=`cygpath -am /`; SYSTEM=${SYSTEM##*/}
homepath() {
  case "$PWD" in
    $HOME*) echo "~${PWD#$HOME}" ;;
    *) cygpath -am "$PWD" ;;
  esac
}
case "$SYSTEM" in
  msys*) C1="1;35" C2="1;34" ;;
  cyg*) C1="0;32" C2="0;33" ;;
  *) C1="38;2;178;182;30" C2="38;2;131;7;70" ;;
esac
PS1='\[\e[${C1}m\]'${SYSTEM:-'$USERNAME@${HOSTNAME%.*}'}'\[\e[0m\] \[\e[${C2}m\]$(homepath -a "$PWD")\[\e[0m\]
$ '
