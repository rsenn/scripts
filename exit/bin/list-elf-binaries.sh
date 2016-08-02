#!/bin/sh
IFS=:; find ${@:-$PATH} -mindepth 1 -maxdepth 1 -type f -exec file "{}" ";" | ${SED-sed} -n "s,: ELF .* executable.*,,p"
