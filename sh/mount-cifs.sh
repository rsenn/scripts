mount_cifs() {
 (while :; do
    case "$1" in
      --username|--user|-u) USERNAME="$2"; shift 2 ;; --username=*|--user=*|-u=*) USERNAME="${1#*=}"; shift ;;
      --password|--pass|-p) PASSWORD="$2"; shift 2 ;; --password=*|--pass=*|-p=*) PASSWORD="${1#*=}"; shift ;;
      *) break ;;
    esac
  done

  [ $# -gt 0 ] && { export CIFSHOST="$1"; shift; }
 
  : ${USERNAME="roman"} 
  : ${PASSWORD="r4eHuJ"} 
  : ${CIFSHOST="192.168.3.195"}
  : ${SUDO="sudo"}

  USER_ID=`id -u` GROUP_ID=`id -g`

  [ "$USER_ID" = 0 ] && : ${MNTBASE=/mnt} || : ${MNTBASE=$HOME/mnt}
   echo "MNTBASE=$MNTBASE" 1>&2

  [ "$#" -le 0 ] && set --  $(get_shares)

  for SHARE ; do
    DEST="$MNTBASE/${MNTPFX:+$MNTPFX-}$SHARE"
    mkdir -p "$DEST"
    (set -x; $SUDO mount -t cifs "//$CIFSHOST/$SHARE" "$DEST" \
      -o "uid=$USER_ID,gid=$GROUP_ID${USERNAME:+,username=$USERNAME${PASSWORD+,password=$PASSWORD}}" || rmdir "$DEST")
  done)
}

get_shares() {
 (if [ -n "$PASSWORD" ] ; then
   trap 'rm -f "$TMPF"' EXIT
   TMPF=$(mktemp)
   echo "$PASSWORD"> "$TMPF"
   exec 0<"$TMPF"
    unset PASS_ARG
  else
    PASS_ARG="--no-pass"
  fi
  smbclient -L "$CIFSHOST" --user "$USERNAME" $PASS_ARG 2>/dev/null | 
  sed \
 '1 {
    :lp1
    /Sharename/! { N; b lp1 }
    N; d
  }
  /^\s*Server\s*Comment/ { 
    :lp2
    N
    $! { b lp2 }
    d
  }
  s|^\s*\([^ ]\+\)\s.*|\1|
  /^Anonymous$/d
  /\$$/d
  ')
}

case "$0" in
  -*)  ;;
  *) mount_cifs "$@" ;;
esac
