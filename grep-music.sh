#!/bin/sh

EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff voc"

exec grep -i -E "$@" "\\.($(IFS='| '; set -- $EXTS;  echo "$*"))\$" 
