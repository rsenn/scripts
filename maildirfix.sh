#!/bin/sh

for M in ${@-/home/*/Maildir}; do
  echo checking $M
  for d in cur new tmp ; do
      [ -d "$M/$d" ] || { echo "* Creating $M/$d"; mkdir "$M/$d"; }
      chown -c --reference "$M" "$M/$d"
      chmod -c 700 "$M/$d"
  done
  find $M -type f -name maildirfolder |   while read ; do
      f=`dirname "$REPLY"`
      echo "  checking $f"
      for d in cur new tmp ; do
          [ -d "$f/$d" ] || { echo "  * Creating $f/$d"; mkdir "$f/$d"; }
          chown -c --reference "$f" "$f/$d"
          chmod -c 700 "$f/$d"
      done
  done
done
