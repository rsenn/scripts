#!/bin/sh
USERNAME="roman.l.senn@gmail.com"
PASSWORD="lalala"
MNTPOINT=$HOME/4shared/

#TEMPFILE=$(mktemp)
#trap 'rm -vf "$TEMPFILE"' EXIT INT TERM
#cat >$TEMPFILE <<EOF 
#$USERNAME
#$PASSWORD
#EOF
#grep -H ".*" "$TEMPFILE"

mount -t davfs http://webdav.4shared.com:80/wa "$MNTPOINT" -o conf="$HOME/.davfs2.conf"

