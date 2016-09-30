#!/bin/sh
dpkg -S "$@" 2>&1 | ${SED-sed} -n '/^dpkg:/ { s,^dpkg: ,,; s, not found\.$,,; p }'

