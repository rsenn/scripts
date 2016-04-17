#!/bin/sh
NL="
"
IFS=:; find ${@:-$PATH} -mindepth 1 -maxdepth 1 -type f -exec file "{}" ";" | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -E ": MS-DOS executable PE  *for MS Windows \((GUI|console)\)" | ${SED-sed} "s/: .*//"
