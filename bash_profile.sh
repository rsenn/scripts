#!/bin/bash

pmods='$MEDIAPATH/pmagic*/pmodules'

set -o vi

IFS="
"

[ "$HOSTNAME" = MSYS ] && OS="Msys"
drives_upper=$'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ'
drives_lower=$'a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\ns\nt\nu\nv\nw\nx\ny\nz'


ansi_cyan='\[\033[1;36m\]' ansi_red='\[\033[1;31m\]' ansi_green='\[\033[1;32m\]' ansi_yellow='\[\033[1;33m\]' ansi_blue='\[\033[1;34m\]' ansi_magenta='\[\033[1;35m\]' ansi_gray='\[\033[0;37m\]' ansi_bold='\[\033[1m\]' ansi_none='\[\033[0m\]'

[ -d /usr/local/gnubin  ] && PATH="/usr/local/gnubin:$PATH"

#PATH="/sbin:/usr/bin:/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/libexec:/usr/local/libexec"
LC_ALL=C
#LOCALE=C
LANG=C
HISTSIZE=32768
HISTFILESIZE=16777216
XLIB_SKIP_ARGB_VISUALS=1

unalias cp mv rm  2>/dev/null


#if [ -z "$COLORS" -o ! -e "$COLORS" ]; then
#  LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:*.wav=00;36:'
#fi

export PATH LC_ALL LOCALE LANG HISTSIZE HISTFILESIZE LS_COLORS

case "$TERM" in
	  xterm*) TERM=rxvt ;;
esac

case "$TERM" in
	xterm|rxvt|screen) TERM="$TERM-256color" ;;
esac

TERM=xterm-256color

alias xargs='xargs -d "\n"'
alias aria2c='aria2c --file-allocation=none --check-certificate=false'


if type gls 2>/dev/null 1>/dev/null; then
  LS=gls
else
  LS=ls
fi

if $LS --help 2>&1 |grep -q '\--color'; then
				LS_ARGS="$LS_ARGS --color=auto"
fi
if $LS --help 2>&1 |grep -q '\--time-style'; then
				LS_ARGS="$LS_ARGS --time-style=+%Y%m%d-%H:%M:%S"
fi
alias ls="$LS $LS_ARGS"

if grep --help 2>&1 |grep -q '\--color'; then
				GREP_ARGS="$GREP_ARGS --color=auto"
fi
if grep --help 2>&1 |grep -q '\--line-buffered'; then
				GREP_ARGS="$GREP_ARGS --line-buffered"
fi
alias grep="grep $GREP_ARGS"
alias cp='cp'
alias mv='mv'
alias rm='rm'

unalias cp  2>/dev/null
unalias mv  2>/dev/null
unalias rm 2>/dev/null

type yum 2>/dev/null >/dev/null && alias yum='sudo yum -y'
type smart 2>/dev/null >/dev/null && alias smart='sudo smart -y'
type apt-get 2>/dev/null >/dev/null && alias apt-get='sudo apt-get -y'
type aptitude 2>/dev/null >/dev/null && alias aptitude='sudo aptitude -y'

#cd() { command cd "$(d "$1")"; }
#pushd() { command pushd "$(d "$1")"; }

. require.sh

require util
require algorithm
require list
require fs

set -o vi

IFS=$'\n\t\r'
TERM=rxvt-256color
HISTFILESIZE=$((HISTSIZE * 512))
LC_ALL="C"

export TERM LC_ALL
alias lsof='lsof 2>/dev/null'

[ -d /cygdrive ]  && { CYGDRIVE="/cygdrive"; OS="Cygwin"; }
[ -d /sysdrive ]  && CYGDRIVE="/sysdrive"


if [ "$PS1" = '\s-\v\$ ' ]; then
  unset PS1
fi

set-prompt()
{
	if [ -r "$HOME/.bash_prompt" ]; then
				 eval "PS1=\"$(<$HOME/.bash_prompt)\""
	else
				PS1="$*"
	fi
}

case "${OS=`uname -o`}" in
   msys* | Msys* |MSys* | MSYS*)
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   ;;
  *cygwin* |Cygwin* | CYGWIN*) 
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   set-prompt '\[\e]0;${OS}\w\a\]\n\[\e[32m\]$USERNAME@${HOSTNAME%.*} \[\e[33m\]\w\[\e[0m\]\n\$ '
  ;;
*) 
  MEDIAPATH="/m*/*/"
  
	set-prompt "${ansi_yellow}\\u${ansi_none}@${ansi_red}${HOSTNAME%[.-]*}${ansi_none}:${ansi_bold}(${ansi_none}${ansi_green}\\w${ansi_none}${ansi_bold})${ansi_none} \\\$ "
 ;;
esac

#: ${PS1:='\[\e]0;$MSYSTEM\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '}

pathmunge()
{
  local IFS=":";
  : ${OS=`uname -o`};
  case "$OS:$1" in
      [Mm]sys:*[:\\]*)
          tmp="$1";
          shift;
          set -- `msyspath "$tmp"` "$@"
      ;;
  esac;
  if ! echo "$PATH" | egrep -q "(^|:)$1($|:)"; then
      if test "$2" = "after"; then
          PATH="$PATH:$1";
      else
          PATH="$1:$PATH";
      fi;
  fi
}
list-mediapath()
{
  for ARG; do
    eval "ls -1 -d  -- $MEDIAPATH/\$ARG 2>/dev/null"
  done
}
add-mediapath()
{
  for ARG; do
    set -- $(eval "list-mediapath $ARG"); while [ "$1" ]; do 
	      D="${1%/}"; [ -d "$D" ] || D=${D%/*}; 
		  [ -d "$D" ] && PATH="$PATH:$D"
		  shift
		  done
  done
}

#echo -n "Adding mediapaths ... " 1>&2; add-mediapath "I386/" "I386/system32/" "Windows/" "Tools/" "HBCD/" "Program*/{Notepad2,WinRAR,Notepad++,SDCC/bin,gputils/bin}/"; echo "done" 1>&2
add-mediapath "Program Files/Notepad2"
add-mediapath Tools/

#for DIR in $(list-mediapath "Prog*"/{UniExtract,Notepad*,WinRAR,7-Zip,WinZip}/ "Tools/" "I386/" "Windows"/{,system32/} "*.lnk"); do
#  DIR=${DIR%/}
#  [ -d "$DIR" ] || DIR=${DIR%/*}
#  pathmunge "${DIR}" after
# done
#
#[ -d "$CYGDRIVE/c/Program Files/WinRAR" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/WinRAR"
#[ -d "$CYGDRIVE/c/Program Files/Notepad2" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/Notepad2"
#[ -d "$CYGDRIVE/c/Program Files/Notepad++" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/Notepad++"
#[ -d "$CYGDRIVE/c/Program Files/SDCC/bin" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/SDCC/bin"
#[ -d "$CYGDRIVE/c/Program Files/gputils/bin" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/gputils/bin"
#[ -d "$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/PM3Cmd" ] && PATH="$PATH:$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/PM3Cmd"
#[ -d "$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/ICD3" ] && PATH="$PATH:$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/ICD3"
#[ -d "$CYGDRIVE/x/I386" ] && PATH="$PATH:$CYGDRIVE/x/I386:$CYGDRIVE/x/I386/system32"
#[ -d "$CYGDRIVE/c/cygwin/bin" ] && PATH="$PATH:$CYGDRIVE/c/cygwin/bin"
#
#CDPATH=".:$CYGDRIVE/c/Users/rsenn"
#
#mediapath()
#{
#  case "$MEDIAPATH" in
#    *{*)
#      MEDIA=$(ls  --color=no -d $MEDIAPATH" 2>/dev/null |sed -n 's,/*$,, ; s,.*/,,; /#[a-z]$/p') 
#      MEDIAPATH="/{$(IFS=",$IFS"; set -- $MEDIA; echo "$*")}"
#      unset MEDIA
#      ;;
#    esac
#    echo "$MEDIAPATH"
#}
#
FNS="$HOME/.bash_functions"

[ -d "x:/Windows" ] && : ${SystemRoot='x:\Windows'}
[ -d "x:/I386" ] && : ${SystemRoot='x:\I386'}

explore()
{
    ( r=$(realpath "$1");
    r=${r%/.};
    r=${r#./};
    p=$(msyspath -w "$r");
    ( set -x;
    cmd /c "${SystemRoot:+$SystemRoot\\}explorer.exe /n,/e,$p" ) )
}

msiexec()
{
    (  while :; do
        case "$1" in
          -* | /?) ARGS="${ARGS+$ARGS }$1"; shift ;;
           *) break ;;
           esac
           done
    
    r=$(realpath "$1");
    r=${r%/.};
    r=${r#./};
    p=$(msyspath -w "$r");
    ( set -x;
    cmd /c "msiexec.exe $ARGS $p" ) )
}

[ -r "$FNS" -a -s "$FNS" ] && . "$FNS"



#
if [ -e /etc/bash_completion -a "${BASH_COMPLETION-unset}" = unset ]; then
				 . /etc/bash_completion
 fi

 
LS_COLORS='di=01;34:ln=01;36:pi=33:so=01;35:do=01;35:bd=33;01:cd=33;01:or=31;01:su=37:sg=30:tw=30:ow=34:st=37:ex=01;33:'
export LS_COLORS
