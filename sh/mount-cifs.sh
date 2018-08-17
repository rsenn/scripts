get-shares() {
 (if [ -n "$PASSWORD" ] ; then
   trap 'rm -f "$TMPF"' EXIT
   TMPF=$(mktemp)
   echo "$PASSWORD"> "$TMPF"
   exec 0<"$TMPF"
    unset PASS_ARG
  else
    PASS_ARG="--no-pass"
  fi
  smbclient \
    -L "$CIFSHOST" \
    --user "$USERNAME" \
    $PASS_ARG \
    2>/dev/null | 
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
mount-cifs () 
{
 : ${USERNAME="roman"} 
 : ${PASSWORD="r4eHuJ"} 
 : ${CIFSHOST=192.168.3.195}


 [ "$#" -le 0 ] && set --  FATBOOT NewData W7x20ALT manjaro roman
    for x ; do
        d=${MNTBASE:-$HOME/mnt}/${MNTPFX:+$MNTPFX-}"$x";
        mkdir -p "$d";
        (set -x; sudo mount -t cifs //${CIFSHOST}/"$x" "$d" -o uid=`id -u`,gid=`id -g`${USERNAME:+,username=$USERNAME${PASSWORD+,password=$PASSWORD}} || rmdir "$d"
)
    done
}
