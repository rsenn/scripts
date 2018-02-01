#!/bin/sh

source-highlight -o /dev/stdout -i Parser.c -f esc --style-file /usr/share/source-highlight/esc.style |
  sed 's,^,\x1b[33m,' | 
  less -R
