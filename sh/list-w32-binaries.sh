#!/bin/sh
IFS=:; find ${@:-$PATH} -mindepth 1 -maxdepth 1 -type f -exec file "{}" ";" | grep -E ": MS-DOS executable PE  *for MS Windows \((GUI|console)\)" | ${SED-sed} "s/: .*//"
