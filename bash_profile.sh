#!/bin/bash

pmods='$MEDIAPATH/pmagic*/pmodules'

set -o vi

IFS="
"

[ "$HOSTNAME" = MSYS ] && OS="Msys"
drives_upper=$'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ'
drives_lower=$'a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\ns\nt\nu\nv\nw\nx\ny\nz'


ansi_red='\[\033[1;31m\]' ansi_green='\[\033[1;32m\]' ansi_yellow='\[\033[1;33m\]' ansi_blue='\[\033[1;34m\]' ansi_magenta='\[\033[1;35m\]' ansi_gray='\[\033[0;37m\]' ansi_bold='\[\033[1m\]' ansi_none='\[\033[0m\]'

PATH="/sbin:/usr/bin:/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/libexec:/usr/local/libexec"
LC_ALL=C
#LOCALE=C
#LANG=C
HISTSIZE=32768
HISTFILESIZE=16777216
LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37:sg=30;40:tw=30;40:ow=34;40:st=37;40:ex=01;32:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:'

unalias cp mv rm  2>/dev/null


if [ -z "$COLORS" -o ! -e "$COLORS" ]; then
  LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:*.wav=00;36:'
fi

export PATH LC_ALL LOCALE LANG HISTSIZE HISTFILESIZE LS_COLORS

case "$TERM" in
	  xterm*) TERM=rxvt ;;
esac

case "$TERM" in
	xterm|rxvt|screen) TERM="$TERM-256color" ;;
esac

TERM=xterm-256color

alias aria2c='aria2c --file-allocation=none --check-certificate=false'
alias ls='ls --color=auto'

#alias grep='grep --color=auto'
alias cp='cp'
alias mv='mv'
alias rm='rm'

unalias cp  2>/dev/null
unalias mv  2>/dev/null
unalias rm 2>/dev/null

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

case "${OS=`uname -o`}" in
   msys* | Msys* |MSys* | MSYS*)
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   ;;
  *cygwin* |Cygwin* | CYGWIN*) 
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   PS1='\[\e]0;$MSYSTEM\w\a\]\n\[\e[32m\]$USERNAME@$HOSTNAME \[\e[33m\]\w\[\e[0m\]\n\$ '
  ;;
*) 
  MEDIAPATH="/m*/*/"
  PS1="${ansi_yellow}\\u${ansi_none}@${ansi_red}${HOSTNAME%%.*}${ansi_none}:${ansi_bold}(${ansi_none}${ansi_green}\\w${ansi_none}${ansi_bold})${ansi_none} \\\$ "
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
    eval "ls -d $MEDIAPATH/\$ARG 2>/dev/null"
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

LS_COLORS='rs=0:di=01;34:ln=01;36:pi=33:so=01;35:do=01;35:bd=33;01:cd=33;01:or=31;01:su=37:sg=30:ca=30:tw=30:ow=34:st=37:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
