while [ $# -gt 0 ]; do
  ARG="$1"
  case "$ARG" in
    --*=* | *=*) ARG=${ARG#--}; eval "${ARG%%=*}=${ARG#*=}" ; shift ;;
  *) break
  esac
done

IFS=" ""
"

: ${IP=192.168.0.16}
: ${USERNAME=roman}
: ${PASSWORD=}

SMB_OUTPUT=`smbclient -L "$IP" --user "$USERNAME${PASSWORD:+%$PASSWORD}" 2>/dev/null`
#echo "$SMB_OUTPUT" |tee o|sed 's,^,output: ,'

: ${SHARES=`echo "$SMB_OUTPUT" | sed -n "/Sharename.*Type/ { :lp1; N; /\n\s*----[^\n]*$/! b lp1; /Workgroup\s\+Master/q; n; :lp2; s,^\s*,, ;; s,\s.*,, ;; /^----/! { /^\s*$/! p; n; $! b lp2; }; b lp1; }" | sed -e '$ { /^Server$/d }' -e '\|\$$|d'`}

: ${SERVNAME=`echo "$SMB_OUTPUT" |sed -n "/^\s*Server\s/ { N; n; s,^\s*\([^ ]\+\).*,\1,p }" | tr "[:"{upper,lower}":]"`}

suexec() {
 (unset CMD
  for ARG; do CMD="${CMD+$CMD; }$ARG"; done
  echo "+ $CMD" 1>&2
  sudo sh -c "$CMD")
}

for x in $SHARES
do (suexec "umount -f '/media/cifs/$SERVNAME/$x' || sudo umount -l '/media/cifs/$SERVNAME/$x'" \
  "mkdir -p '/media/cifs/$SERVNAME/$x'"

(
suexec "mount -t cifs '//$IP/$x' '/media/cifs/$SERVNAME/$x' -o 'username=$USERNAME,password=$PASSWORD,uid=$UID,gid=${GROUPS%%[![:alnum:]]*}'"

) )
done