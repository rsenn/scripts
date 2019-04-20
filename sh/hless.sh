#!/bin/sh

case "$1" in 
  *.md) s=todo ;;
esac

source-highlight -o /dev/stdout ${s+-s "$s"} -i "$1" -f esc --style-file /usr/share/source-highlight/esc.style |
  sed 's,^,\x1b[33m,' | 
  less -R
