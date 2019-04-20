#!/bin/sh

global_syms() {
  while :; do
    case "$1" in
      -U|--undefined) UNDEFINED=true ;;
      -D|--defined) DEFINED=true ;;
      *) break ;;
    esac
    shift
  done

  if [ "$UNDEFINED" = true ]; then
    FILTER="/\sU\s/! { /\*UND\*/! { d } }"
  elif [ "$DEFINED" = true ]; then
    FILTER="/\sU\s/d ;; /\*UND\*/d"
  fi
  FILTER_COL="\s\+[^ ]\+"
  FILTER="$FILTER ;; \\|\*UND\*| s|:\s\+\([[:xdigit:]]\+\)\s\s|: \1 U|"
  FILTER="$FILTER ;; s|:\s\?\([[:xdigit:]]\+\)\s\(.\)..............\s*\([[:xdigit:]]\+\)\s............\s|:\1 \2 |"
  FILTER="/ [^ ] [^ ]\+\$/ { / [^. ]\+\$/! { d } } ;; $FILTER"
  FILTER="$FILTER ;; /DYNAMIC SYMBOL TABLE:/d ;; /\sfile\sformat\s/d"
  FILTER="$FILTER ;; /\sr\s/d"

  find "${@:-.}" -not -type d | xargs -d '\n' file |
    grep -E ': .*ELF.*(relocatable|shared)' | { IFS=":"; 
  while read -r FILE MAGIC; do
    case "$FILE:$MAGIC" in
      *.o:* | *:*relocatable*) nm -A "$FILE" ;;
      *.so* | *:*shared*) objdump -T "$FILE" | sed "\\|^\s*\$|d ; s|^|$FILE: |" ;;
    esac 
  done| sed "$FILTER"
  }
}


case "$0" in
  -*) ;;
  *) global_syms "$@" ;;
esac
