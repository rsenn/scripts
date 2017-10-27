#!/bin/sh

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

	blkid | { IFS=":"; while read -r  DEV VARS; do
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

case "${0##*/}" in
  -* | sh | bash) ;;
  *) mkfsck "$@" || exit $? ;;
esac


