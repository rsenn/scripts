list-devices-by () 
{ 
 (TMP=`mktemp` TMP2=`mktemp` IFS=" "
  trap 'rm -f "$TMP"' EXIT

<<<<<<< HEAD
    command ls -ldn --time-style=+%s -- /dev/disk/by-{label,uuid}/* >"$TMP2" 2>/dev/null; RET=$?; 
    [ "$RET" != 0 ] && exit $RET
    sort -t'>' -k2 <"$TMP2" >"$TMP"
=======
	{
    ls -ldn --time-style=+%s -- /dev/disk/by-{label,uuid}/* 
    ls -ldn --time-style=+%s -- /dev/*/* 2>/dev/null |sed -n '\|dev/disk|d; \|dev/block|d; \|dev/mapper|d; \| -> \.\./dm-|p'
	} >"$TMP2" 2>/dev/null; RET=$?; 
  [ "$RET" != 0 ] && exit $RET
  sort -t'>' -k2 <"$TMP2" >"$TMP"
>>>>>>> 53c01fbadebe5837705f5bfbba93b4f8409f3f46

  while read MODE N U G S T F __ L ; do
    while :; do
      unset LABEL UUID TYPE
            read MODE2 N2 U2 G2 S2 T2 F2 __ L2


            D=/dev/${L##*/}     
						[ -n "$D" -a -d "$D" ] && continue  2

            MAGIC=`file -k - <"$D"`
            [ "$DEBUG" = true ]  && echo  "MODE='$MODE' N='$N' F='$F' D='$D'"  1>&2

						case "$D" in
										/dev/dm-*) D="$F" ;;
						esac


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
						[ -z "$LABEL" ] && LABEL=${F##*/}

            echo "$D:${LABEL:+ LABEL=\"$LABEL\"}${UUID:+ UUID=\"$UUID\"}${TYPE:+ TYPE=\"$TYPE\"}"
            
            
        if [ "$L" != "$L2" ]; then
              N=$N2; U=$U2; G=$G2; S=$S2; T=$T2; F=$F2 L=$L2
              continue
      fi
      break
    done

           
  done <"$TMP")

<<<<<<< HEAD
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

             
    done <"$TMP") || blkid

    #ls -d /dev/disk/by-label/* | for_each -f 'echo "$(readlink -f "$1"): LABEL=\"${1##*/}\""';
    #ls -d /dev/disk/by-uuid/* | for_each -f 'echo "$(readlink -f "$1"): UUID=\"${1##*/}\""'
=======
  #ls -d /dev/disk/by-label/* | for_each -f 'echo "$(readlink -f "$1"): LABEL=\"${1##*/}\""';
  #ls -d /dev/disk/by-uuid/* | for_each -f 'echo "$(readlink -f "$1"): UUID=\"${1##*/}\""'
>>>>>>> 53c01fbadebe5837705f5bfbba93b4f8409f3f46
}
