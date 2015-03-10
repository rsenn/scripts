echo 'loading /home/roman/.bash_profile' 1>&2
#!/bin/bash

set -o vi

IFS="
"

PATH="/bin:$PATH"

[ "$HOSTNAME" = MSYS -o -n "$MSYSTEM" ] && OS="Msys"
[ "$OSTYPE" ] && OS="$OSTYPE"

: ${OS=`uname -o 2>/dev/null || uname -s 2>/dev/null`}

pmods='$MEDIAPATH/pmagic*/pmodules'
drives_upper=$'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ'
drives_lower=$'a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\ns\nt\nu\nv\nw\nx\ny\nz'

ansi_cyan='\[\033[1;36m\]' ansi_red='\[\033[1;31m\]' ansi_green='\[\033[1;32m\]' ansi_yellow='\[\033[1;33m\]' ansi_blue='\[\033[1;34m\]' ansi_magenta='\[\033[1;35m\]' ansi_gray='\[\033[0;37m\]' ansi_bold='\[\033[1m\]' ansi_none='\[\033[0m\]'

[ -d /usr/local/gnubin  ] && PATH="$PATH:/usr/local/gnubin"

LANG=en_US
LC_ALL=C
LC_CTYPE=en_US.ISO-8859-1
HISTFILESIZE=16777216
HISTSIZE=94208
XLIB_SKIP_ARGB_VISUALS=1
LESS="-R"
IFS=$'\n\t\r'
HISTFILESIZE=$((HISTSIZE * 512))

case "$TERM" in
  *256color*) ;;
  konsole|screen|rxvt|vte|Eterm|putty|xterm|mlterm|mrxvt|gnome) TERM="$TERM-256color" ;;
esac

unalias cp mv rm  2>/dev/null

case "$TERM" in
    xterm*) TERM=rxvt ;;
esac
case "$TERM" in
  xterm|rxvt|screen) TERM="$TERM-256color" ;;
esac

export LC_ALL LC_CTYPE LANG HISTSIZE HISTFILESIZE XLIB_SKIP_ARGB_VISUALS LESS LS_COLORS TERM

has_cmd() {
  test -e /bin/"$1" -o -e /usr/bin/"$1"
	#type "$1" >/dev/null 2>/dev/null
}
	
has_cmd gxargs && alias xargs='gxargs -d "\n"' || alias xargs='xargs -d "\n"'

alias aria2c='aria2c --file-allocation=none --check-certificate=false'

has_cmd gls && alias ls="gls \$LS_ARGS" || alias ls="ls \$LS_ARGS"

if ls --help 2>&1 | grep -q '\--color'; then
  LS_ARGS="--color=auto"
fi

#for BIN in \
#	awk base64 basename cat chcon chgrp chmod chown chroot cksum comm cp \
#	csplit cut date dd df dir dircolors dirname du env expand expr factor \
#	false find fmt fold groups head hostid id install join kill libtool \
#	libtoolize link ln locate logname m4 md5sum mkdir mkfifo mknod mktemp mv \
#	nice nl nohup nproc numfmt od oldfind paste pathchk pinky pr printenv printf \
#	ptx pwd readlink realpath rm rmdir runcon sed seq sha1sum sha224sum sha256sum \
#	sha384sum sha512sum shred shuf sleep sort split stat stdbuf stty sum sync tac \
#	tail tee test timeout touch tr true truncate tsort tty uname unexpand uniq \
#	unlink updatedb uptime users vdir wc who whoami xargs yes
#do
#	 has_cmd "g$BIN" && alias "$BIN=g$BIN"
#done

if grep --help 2>&1 | grep -q '\--color'; then
	GREP_ARGS="${GREP_ARGS:+$GREP_ARGS }--color=auto"
fi

if grep --help 2>&1 | grep -q '\--line-buffered'; then
	GREP_ARGS="${GREP_ARGS:+$GREP_ARGS }--line-buffered"
fi

alias grep="/bin/grep $GREP_ARGS"
alias grepdiff='grepdiff --output-matching=hunk'

#unalias cp  2>/dev/null
#unalias mv  2>/dev/null
#unalias rm 2>/dev/null

if [ "`id -u`" = 0 ]; then
    SUDO=command
else
    SUDO=sudo
fi
type gvim 2>/dev/null >/dev/null && alias gvim="gvim -p"
type astyle 2>/dev/null >/dev/null && alias astyle="astyle --style=linux --indent=spaces=2 "
type yum 2>/dev/null >/dev/null && alias yum="$SUDO yum -y"
type smart 2>/dev/null >/dev/null && alias smart="$SUDO smart -y"
type zypper 2>/dev/null >/dev/null && alias zypper="$SUDO zypper"
type apt-get 2>/dev/null >/dev/null && alias apt-get="$SUDO apt-get -y"
type aptitude 2>/dev/null >/dev/null && alias aptitude="$SUDO aptitude -y"

if has_cmd require.sh; then
  . require.sh
	
  require util
  require algorithm
  require list
  require fs
fi


alias lsof='lsof 2>/dev/null'

[ "$PS1" = '\s-\v\$ ' ] && unset PS1

set-prompt()
{ [ -r "$HOME/.bash_prompt" ] && eval "PS1=\"$(<$HOME/.bash_prompt)\"" || PS1="$*"; }

[ -d /cygdrive ]  && { CYGDRIVE="/cygdrive"; : ${OS="Cygwin"}; }
#[ -d /sysdrive ]  && SYSDRIVE="/sysdrive" || SYSDRIVE=
(set -- /sysdrive/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}/; for DRIVE do test -d "$DRIVE" && exit 0; done; exit 1) && SYSDRIVE="/sysdrive" || unset SYSDRIVE

currentpath()
{
 (CWD="${1-$PWD}"
  [ "$CWD" != "${CWD#$HOME}" ] && CWD="~${CWD#$HOME}" || { [ "$PATHTOOL" ] && CWD=`$PATHTOOL -m "$CWD"`; }
  [ "$CWD" != "${CWD#$SYSROOT}" ] && CWD=${CWD#$SYSROOT}
  echo "$CWD")
}

case "${OS}" in
   msys* | Msys* |MSys* | MSYS*)
    MEDIAPATH="$SYSDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
    PATHTOOL=msyspath
    MSYSROOT=`msyspath -m / 2>/dev/null`

    set-prompt '\e[32m\]\u@\h \[\e[33m\]$(CWD="${PWD}";[ "$CWD" != "${CWD#$HOME}" ] && CWD="~${CWD#$HOME}" || { [ "$PATHTOOL" ] && CWD=$($PATHTOOL -m "$CWD"); }; [ "$CWD" != "${CWD#$SYSROOT}" ] && CWD=${CWD#$SYSROOT}; echo "$CWD")\[\e[0m\]\n\$ '
   ;;
  *cygwin* |Cygwin* | CYGWIN*) 
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   set-prompt '\[\e]0;${OS}\w\a\]\n\[\e[32m\]$USERNAME@${HOSTNAME%.*} \[\e[33m\]$(CWD="${PWD}";[ "$CWD" != "${CWD#$HOME}" ] && CWD="~${CWD#$HOME}" || { [ "$PATHTOOL" ] && CWD=$($PATHTOOL -m "$CWD"); }; [ "$CWD" != "${CWD#$SYSROOT}" ] && CWD=${CWD#$SYSROOT}; echo "$CWD")\[\e[0m\]\n\$ '
   PATHTOOL=cygpath
   CYGROOT=`cygpath -m /`
  ;;
*) 
  MEDIAPATH="/m*/*/"  
  if [ -e ~/.bash_prompt ]; then
    set-prompt
  else
    case "$PS1" in
      *\\033*) ;;
      *) : set-prompt "${ansi_yellow}\\u${ansi_none}@${ansi_red}${HOSTNAME%[.-]*}${ansi_none}:${ansi_bold}(${ansi_none}${ansi_green}\\w${ansi_none}${ansi_bold})${ansi_none} \\\$ " ;;
    esac
  fi
 ;;
esac

#: ${PS1:='\[\e]0;$MSYSTEM\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '}

pathmunge() {
  while :; do
    case "$1" in
      -v) PATHVAR="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  local IFS=":";
  : ${OS=`uname -o | head -n1`};
  case "$OS:$1" in
      [Mm]sys:*[:\\]*)
          tmp="$1";
          shift;
          set -- `$PATHTOOL "$tmp"` "$@"
      ;;
  esac;
  if ! eval "echo \"\${${PATHVAR-PATH}}\"" | /bin/grep -E -q "(^|:)$1($|:)"; then
      if test "$2" = "after"; then
          eval "${PATHVAR-PATH}=\"\${${PATHVAR-PATH}}:\$1\"";
      else
          eval "${PATHVAR-PATH}=\"\$1:\${${PATHVAR-PATH}}\"";
      fi;
  fi
  unset PATHVAR
}

pathremove() {
  old_IFS="$IFS"
  IFS=":"
	RET=1
  unset NEWPATH

  for DIR in $PATH; do
    for ARG; do
      case "$DIR" in
        $ARG) RET=0; continue 2 ;;
      esac
    done
    NEWPATH="${NEWPATH+$NEWPATH:}$DIR"
  done

  PATH="$NEWPATH"
  IFS="$old_IFS"
  unset NEWPATH old_IFS
	return $RET
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
      if [ -d "$D" ]; then
         [ "$ADD" = before ] && PATH="$D:$PATH" || PATH="$PATH:$D"
      fi
      shift
      done
  done
}

#is-cmd() { type "$1" >/dev/null 2>/dev/null; }

#echo -n "Adding mediapaths ... " 1>&2; add-mediapath "I386/" "I386/system32/" "Windows/" "Tools/" "HBCD/" "Program*/{Notepad2,WinRAR,Notepad++,SDCC/bin,gputils/bin}/"; echo "done" 1>&2
#is-cmd "notepad2" || add-mediapath "Prog*/Notepad2"

ADD=after add-mediapath Tools/

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

FNS="$HOME/.bash_functions"

[ -r "$FNS" -a -s "$FNS" ] && . "$FNS"

[ -d "$USERPROFILE" -a -n "$PATHTOOL" ] && CDPATH=.:`$PATHTOOL "$USERPROFILE"`

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

[ -d "x:/Windows" ] && : ${SystemRoot='x:\Windows'}
[ -d "x:/I386" ] && : ${SystemRoot='x:\I386'}

explore()
{
 (r=`realpath "$1" 2>/dev/null`; [ "$r" ] || r=$1
  r=${r%/.}
  r=${r#./}
  p=`$PATHTOOL -w "$r"`
  set -x
  "${SystemRoot:+$SystemRoot\\}explorer.exe" "/n,/e,$p"
 )
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
    p=$($PATHTOOL -w "$r");
    ( set -x;
    cmd /c "msiexec.exe $ARGS $p" ) )
}

if [ -e /etc/bash_completion -a "${BASH_COMPLETION-unset}" = unset ]; then
  . /etc/bash_completion
fi
 
CDPATH="."

if [ -n "$USERPROFILE" -a -n "$PATHTOOL" ]; then
  USERPROFILE=`$PATHTOOL -m "$USERPROFILE"`
  if [ -d "$USERPROFILE" ]; then
     pathmunge -v CDPATH "`$PATHTOOL "$USERPROFILE"`" after
  
    DESKTOP="$USERPROFILE/Desktop" DOCUMENTS="$USERPROFILE/Documents" DOWNLOADS="$USERPROFILE/Downloads" PICTURES="$USERPROFILE/Pictures" VIDEOS="$USERPROFILE/Videos"    MUSIC="$USERPROFILE/Music"
    
    [ -d "$DOCUMENTS/Sources" ] && SOURCES="$DOCUMENTS/Sources"
    
    pathmunge -v CDPATH "$($PATHTOOL "$DOCUMENTS")" after
    pathmunge -v CDPATH "$($PATHTOOL "$DESKTOP")" after
  fi
fi

if [ -z "$DESKTOP" -a -n "$HOME" ]; then
	[ -d "$HOME/Desktop" ] && DESKTOP="$HOME/Desktop"
	[ -d "$HOME/Documents" ] && DOCUMENTS="$HOME/Documents"
	[ -d "$HOME/Downloads" ] && DOWNLOADS="$HOME/Downloads"
	[ -d "$HOME/Pictures" ] && PICTURES="$HOME/Pictures"
	[ -d "$HOME/Videos" ] && VIDEOS="$HOME/Videos"
	[ -d "$HOME/Music" ] && MUSIC="$HOME/Music"
fi

case "$MSYSTEM" in
  *MINGW32*) [ -d /mingw/bin ] && pathmunge /mingw/bin ;;
  *MINGW64*) [ -d /mingw64/bin ] && pathmunge /mingw64/bin ;;
  *) LS_COLORS='di=01;34:ln=01;36:pi=35:so=01;35:do=01;35:bd=35;01:cd=35;01:or=31;01:ex=01;35:tw=1;34:ow=1;34'; export LS_COLORS
;;
esac

#[ -d /sbin ] && pathmunge /sbin
#[ -d /usr/sbin ] && pathmunge /usr/sbin

pathremove /bin && pathmunge /bin
pathremove /sbin && pathmunge /sbin
pathremove /usr/bin && pathmunge /usr/bin
pathremove /usr/sbin && pathmunge /usr/sbin

pathremove /usr/local/bin && pathmunge /usr/local/bin 
pathremove /usr/local/sbin && pathmunge /usr/local/sbin

