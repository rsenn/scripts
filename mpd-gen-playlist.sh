#!/bin/sh

: ${MPD_HOST:="lala@localhost"}

#COND="-and -size +30M"
COND=
IFS="
"

find */ -type f -follow \( -iname "*.mp3" -or -iname "*.ogg" \) $COND |
while read x; do 
  alpha=`echo "${x##*/}" | sed "s,^[^A-Za-z]*,,"`
  test -r "$x" && echo "$alpha:$x"
done | {
  unset tracks prev
  sort -f -k1 -u -t":" |  {
    IFS=":"
    mpc clear
    while read name path; do 
      if ! [ "$prev" -ef "$path" ]; then
        echo "$name" 1>&2
        mpc add "$path"
#       tracks="${tracks+$tracks
#}$path"
        prev="$path"
      fi
    done
  }
}
