#!/bin/bash

pushv() { eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""; }

mkfsck() {
 (debug() {
    ${DEBUG:-false} && echo "DEBUG: $@" 1>&2
  }
  CHARSET=$EXTRACHARS'0-9A-Za-z_' COUNT=0

  unset OPTS PATTERN REPLACE SCRIPT PREV

  #DEBUG=true debug "echo $0 $@"

  while :; do
    case "$1" in
        --debug | -x) DEBUG=:; shift ;;
       -*) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
      *) break ;;
    esac
  done

	(list-devices-by || blkid) | { IFS=":"; while read -r  DEV VARS; do
	 (unset LABEL UUID TYPE PTTYPE 
	  IFS=" "
    eval "$VARS"
   
	  case $TYPE in
		        swap | squashfs | ntfs) continue ;;
		        vfat|fat*) CMD="dosfsck -f -v -y $DEV" ;;
		        ntfs*) CMD="ntfsfix $DEV" ;;
						*) CMD="fsck.$TYPE -f -v -y $DEV" ;;
		esac
		COMMENT=
	  [ -n "$LABEL" ] && pushv COMMENT  "LABEL=\"$LABEL\""
	  [ -n "$UUID" ] && pushv COMMENT  "UUID=\"$UUID\""
		set -- "$CMD" "${COMMENT:+# $COMMENT}"
		eval "printf '%-40s %s\\n' \"\$@\""

	  
		); done; }
		)
}

list-devices-by () 
{ 
 (TMP=`mktemp` IFS=" "
  trap 'rm -f "$TMP"' EXIT

    ls -ldn --time-style=+%s -- /dev/disk/by-{label,uuid}/* 2>/dev/null |sort -t'>' -k2 >"$TMP"

		[ -f "$TMP" -a  -s "$TMP" ] || exit $?

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

case "${0##*/}" in
  -* | sh | bash) ;;
  *) mkfsck "$@" || exit $? ;;
esac


