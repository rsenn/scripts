#!/bin/sh

for CMD in davfs wdfs; do
  if type "$CMD" >&/dev/null; then
    break
  fi
done


USERNAME="roman.l.senn@gmail.com"
PASSWORD="lalala"
MNTPOINT=${1:-"$HOME/4shared/"}

#TEMPFILE=$(mktemp)
#trap 'rm -vf "$TEMPFILE"' EXIT INT TERM
#cat >$TEMPFILE <<EOF 
#$USERNAME
#$PASSWORD
#EOF
#grep -H ".*" "$TEMPFILE"


mkdir -p "$MNTPOINT"

case "$CMD" in
  davfs) 
    sudo mount -t davfs http://webdav.4shared.com:80/wa "$MNTPOINT" -o rw,conf="$HOME/.davfs2.conf",uid=`id -u`,gid=`id -g`
  ;;
  wdfs)
    wdfs http://webdav.4shared.com:80/wa "$MNTPOINT" -o rw,username="$USERNAME",password="$PASSWORD",uid=`id -u`,gid=`id -g`
  ;;
esac
