while [ $# -gt 0 ]; do
  ARG="$1"
  case "$ARG" in
    --*=* | *=*) ARG=${ARG#--}; eval "${ARG%%=*}=${ARG#*=}" ; shift ;;
  *) break
  esac
done

: ${MNTDIR='/media/cifs/$SERVNAME'}
IFS=" ""
"

: ${IP=192.168.0.10}
: ${CIFSUSER=roman}

if [ "${PASSWORD+set}" != set ]; then
   read -p "Password: " -s PASSWORD
 fi

SMB_OUTPUT=`smbclient -L "$IP" --user "$CIFSUSER${PASSWORD:+%$PASSWORD}" 2>/dev/null`
#echo "$SMB_OUTPUT" |tee o|${SED-sed} 's,^,output: ,'

: ${SHARES=`echo "$SMB_OUTPUT" | ${SED-sed} -n "/Sharename.*Type/ { :lp1; N; /\n\s*----[^\n]*$/! b lp1; /Workgroup\s\+Master/q; n; :lp2; s,^\s*,, ;; s,\s.*,, ;; /^----/! { /^\s*$/! p; n; $! b lp2; }; b lp1; }" | ${SED-sed} -e '$ { /^Server$/d }' -e '\|\$$|d'`}

: ${SERVNAME=`echo "$SMB_OUTPUT" |${SED-sed} -n "/^\s*Server\s/ { N; n; s,^\s*\([^ ]\+\).*,\1,p }" | tr "[:"{upper,lower}":]"`}

eval "MNTDIR=\"${MNTDIR}\""

suexec() {
 (unset CMD
  for ARG; do CMD="${CMD+$CMD; }$ARG"; done
  echo "+ $CMD" 1>&2
  sudo sh -c "$CMD")
}

get_shares() {
	[ $# -le 0 ] && set -- $SHARES
	for A; do
		for S in $SHARES; do
		  case "$S" in
				$A | */${A}) echo "$S" ;;
		  esac
		done
	done
}

echo "Shares: $SHARES"

for x in $(get_shares "$@")
do (suexec "umount -f '$MNTDIR/$x'  2>/dev/null || sudo umount -l '$MNTDIR/$x' 2>/dev/null" \
  "mkdir -p '$MNTDIR/$x'"

(
suexec "mount -t cifs '//$IP/$x' '$MNTDIR/$x' -o 'username=$CIFSUSER,password=$PASSWORD,uid=$UID,gid=${GROUPS%%[![:alnum:]]*}'"

) )
done
