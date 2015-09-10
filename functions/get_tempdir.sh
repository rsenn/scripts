get_tempdir() {
 (TEMPDIR= 
  if type reg 2>/dev/null >/dev/null; then
    TEMPDIR=`reg query 'HKCU\Environment' '/v' TEMP | sed -n 's|.*REG_SZ\s\+\(.*\)|\1|p'`
    [ -d "$TEMPDIR" ] || TEMPDIR=
  fi
  if [ -z "$TEMPDIR" ]; then
    if [ -n "$TMP" -a -d "$TMP" ]; then
      TEMPDIR="$TMP"
    elif [ -n "$TEMP" -a -d "$TEMP" ]; then
      TEMPDIR="$TEMP"
    elif [ -d "/tmp" ]; then
      TEMPDIR="/tmp"
    fi
  fi
  echo "${TEMPDIR//"\\"/"/"}")
}
