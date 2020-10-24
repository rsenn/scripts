#!/bin/sh

process() {
  PROG=$1 #`realpath "$1"`
  REAL=`realpath "$PROG"`
  DIR=$(dirname "$1")
  TYPE=`file "$PROG"`

  case $TYPE in
    *:\ PE*executable*x86?64*) WINEARCH=win64 ;;
    *:\ PE*executable*) WINEARCH=win32 ;;
    *)
      echo "$1: Not a PE executable" 1>&2
      exit 1
    ;;
  esac
  case $WINEARCH in
    win64) : ${WINEPREFIX=\$HOME/.wine64} ;;
    win32) : ${WINEPREFIX=\$HOME/.wine32} ;;
  esac
  case $WINEARCH in
    win64) : ${WINE=wine64} ;;
    win32) : ${WINE=wine} ;;
  esac

  eval PREFIX=\"$WINEPREFIX\"
  BASE=`basename "$PROG" .exe`
  DEST=$DIR/$BASE 
  PROGDIR=\$THISDIR/
  case $REAL in
    $PREFIX/drive_*) 
      DRIVE=${REAL##*/drive_}; DRIVE=${DRIVE%%/*} 
      FOLDER=${REAL##*/drive_}; FOLDER=${FOLDER#*/}; FOLDER=$(echo "$FOLDER"| sed 's,/,\\\\,g')
      PROGDIR="$DRIVE:\\\\${FOLDER%$BASE.*}"
      ;;
  esac

  cat >$DEST <<EOF
#!/bin/sh
THISDIR=\$(dirname "\$0")
exec env WINEARCH="$WINEARCH" WINEPREFIX="$WINEPREFIX" $WINE "$PROGDIR$BASE.exe" "\$@"
EOF

  chmod +x "$DEST"

  echo "Created '$DEST'." 1>&2
}

main() {
  unset WINEARCH
  unset WINEPREFIX

  for ARG; do (process "$ARG") || return $?; done
}

main "$@"
