#!/bin/sh

PROG=`realpath "$1"`
TYPE=`file "$PROG"`

case $TYPE in
  *:\ PE*executable*) ;;
  *)
    echo "$1: Not a PE executable" 1>&2
    exit 1
  ;;
esac

BASE=`basename "$PROG" .exe`

case `id -u` in
  0) DEST=/usr/bin/$BASE ;;
  *) DEST=$BASE ;;
esac

cat >$DEST <<EOF
#!/bin/sh
exec wine "$PROG" "\$@"
EOF

chmod +x "$DEST"

echo "Created $DEST ." 1>&2
