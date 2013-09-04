#!/bin/sh
dpkg -S "$@" 2>&1 | sed -n '/^dpkg:/ { s,^dpkg: ,,; s, not found\.$,,; p }'

