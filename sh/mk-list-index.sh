#!/bin/bash
 
#MYNAME=`basename "$0" .sh`
mk-list-index() {
 
: ${TEMP="c:/Temp"}

volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
      NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
      eval "$ECHO"
  done)
}

[ -n "$LIST_R64" ] && LIST_R64=$(cygpath -w "$LIST_R64")

{ 
  echo "@echo off
"
  if [ $# -le 0 ]; then
    if [ "$(uname -o)" = Cygwin ]; then
      set -- /cygdrive/?
    fi
    set -- $(volname  $(df -l "$@" | sed 1d |sort -nk3 |awk '{ print $6 }' ) |grep -viE '(ubuntu|fedora|UDF Volume|opensuse|VS201[0-9]|ext[234]|arch)'|sed 's,/.*,,')
  fi
  for D; do 
    P=$(cygpath "$D\\")

    N=$(volname "$P")
    W=${D//"/"/"\\"}
    W=${W##\\}
    echo "echo Indexing $D ($N)
${D%%/*}
cd \\${W#?:}
${LIST_R64:-list-r64} >files.tmp
del /f files.list
move files.tmp files.list
"
  done 
} |
unix2dos |
 (set -x; tee "E:/Temp/list-index.cmd" >/dev/null)

}
