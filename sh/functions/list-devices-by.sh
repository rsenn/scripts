list-devices-by () 
{ 
 (TMP=`mktemp` TMP2=`mktemp` IFS=" "
  trap 'rm -f "$TMP"' EXIT

    ls -ldn --time-style=+%s -- /dev/disk/by-{label,uuid}/* >"$TMP2" ; RET=$?; 
    [ "$RET" != 0 ] && exit $RET
    sort -t'>' -k2 <"$TMP2" >"$TMP"

    while read MODE N U G S T F __ L ; do
      while :; do
        unset LABEL UUID TYPE
              read MODE2 N2 U2 G2 S2 T2 F2 __ L2


              D=/dev/${L##*/}     
              MAGIC=`file -k - <"$D"`
        #      echo  "$F $D" 

              case "$F" in
                      */by-label/*) LABEL=${F##*/} ;;
                      */by-uuid/*) UUID=${F##*/} ;;
              esac

              [ "$L" = "$L2" ] && 
              case "$F2" in
                      */by-label/*) LABEL=${F2##*/} ;;
                      */by-uuid/*) UUID=${F2##*/} ;;
              esac  

                case "$MAGIC" in
                        *NTFS*) TYPE="ntfs" ;;
                        *ext2*) TYPE="ext2" ;;
                        *ext3*) TYPE="ext3" ;;
                        *ext4*) TYPE="ext4" ;;
                        *FAT\ \(32*) TYPE="vfat" ;;
                        *FAT\ *) TYPE="fat" ;;
                        *\ filesystem*) TYPE=${MAGIC%%" filesystem"*}; TYPE=${TYPE##*" "} ;;
                        *\ swap*) TYPE="swap" ;;
                        *) TYPE= ;;
                esac

              echo "$D:${LABEL:+ LABEL=\"$LABEL\"}${UUID:+ UUID=\"$UUID\"}${TYPE:+ TYPE=\"$TYPE\"}"
              
              
          if [ "$L" != "$L2" ]; then
                N=$N2; U=$U2; G=$G2; S=$S2; T=$T2; F=$F2 L=$L2
                continue
        fi
        break
      done

             
    done <"$TMP")

    #ls -d /dev/disk/by-label/* | for_each -f 'echo "$(readlink -f "$1"): LABEL=\"${1##*/}\""';
    #ls -d /dev/disk/by-uuid/* | for_each -f 'echo "$(readlink -f "$1"): UUID=\"${1##*/}\""'
}
