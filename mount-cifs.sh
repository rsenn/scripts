

SHARES='ubuntu13-10 BOOTFAT toshiba windows7 sandisk8'
: ${IP=192.168.0.16}
: ${USERNAME=roman}
: ${PASSWORD=}
SHARES=` smbclient -L "$IP" --user "$USERNAME${PASSWORD:+%$PASSWORD}" 2>/dev/null|sed -n "/Sharename.*Type/ { :lp1; N; /\n\s*----[^\n]*$/! b lp1; /Workgroup\s\+Master/q; n; :lp2; s,^\s*,, ;; s,\s.*,, ;; /^----/! { /^\s*$/! p; n; $! b lp2; }; b lp1; }" | sed -e '$ { /^Server$/d }' -e '\|\$$|d'`      

for x in $SHARES
do (sudo umount -f /media/cifs/gatling/"$x"
sudo  mkdir -p  /media/cifs/gatling/"$x"
(set -x
sudo mount -t cifs {//$IP,/media/cifs/gatling}/"$x" -o username=$USERNAME,password=$PASSWORD,uid=$UID,gid=${GROUPS%%[![:alnum:]]*}) )
done
