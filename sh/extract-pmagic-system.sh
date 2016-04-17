#!/bin/sh
NL="
"

list_7z() {
  7z l -slt "$1" | (IFS=" "; while read -r NAME EQ VALUE; do
  case "$NAME" in
    Path) F="$VALUE" ;;
    Folder) if [ "$VALUE" = + ]; then
        echo "$F/"
      else
        echo "$F"
      fi
    ;;
    *) ;;
    esac
    test -z "$NAME" && unset F
  done)
}

get_version_and_arch() {
  V=$(echo "$1" | ${SED-sed} 's,.*pmagic[^[:alnum:]]*,,i ;; s,\.iso$,,i ;; s,\([0-9][0-9][0-9][0-9]\)_\([0-9][0-9]\)_\([0-9][0-9]\),\1\2\3, ;; s,[-_]\(i[0-9]86\),-\1, ;; s,[-_]\(x86.64\),-\1,')
  echo "$V"
}

process_iso() {
  (MYNAME=${0##*/}
   MYBASE=${MYNAME%.sh}
  LIST=`mktemp /tmp/"$MYBASE"-XXXXXX` 
  trap 'rm -rf "$LIST"' EXIT

  list_7z "$1" >"$LIST"

  ${GREP-grep -a --line-buffered --color=auto} -iE '(/initr[^/]*\.img$|/bzImage|\.SQFS$)' "$LIST"
  )
}

