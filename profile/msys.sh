msys_here() {
 (D=${1:-${PWD:-`pwd`}}
 if [ "${PATHTOOL+set}" != set ]; then
 for TOOL in pathtool cygpath; do 
  if type $TOOL 2>/dev/null >/dev/null; then PATHTOOL="$TOOL
-m"; break
fi; done
  fi
  case "$D" in
    $HOME/*) D="~/${D#$HOME/}" ;;
    $HOME) D="~" ;;
    /cygdrive/?/* | /cygdrive/*) DRIVE="${D#/cygdrive/}"; DRIVE="${DRIVE%%[:/]*}"; D="$DRIVE:/${D#/cygdrive/?/}" ;;
    /?/* | /*) DRIVE="${D#/}"; DRIVE="${DRIVE%%[:/]*}"; D="$DRIVE:/${D#/?/}" ;;
    /*) D=`$PATHTOOL "$D"` ;;
  esac
  echo "$D")
}

case "$OSTYPE":"$MSYSTEM" in
  cygwin:*) PS1='\[\e]0;`msys_here`\a\]\n\[\e[32m\]\u@\h \[\e[33m\]`msys_here`\[\e[0m\]\n\$ ' ;;
  msys:*) PS1='\[\e]0;`msys_here`\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]`msys_here`\[\e[0m\]\n\[\e[1m\]#\[\e[0m\] ' ;;
esac
