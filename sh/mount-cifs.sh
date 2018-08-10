mount-cifs () 
{
 : ${USERNAME="madeleine"} 
 : ${PASSWORD="mase11.02"} 
 [ "$#" -le 0 ] && set --  BCPY-170909 BOOT Daten madeleine System-reserviert w10x64
    for x ; do
        d=${MNTBASE:-$HOME/mnt}/${MNTPFX:+$MNTPFX-}"$x";
        mkdir -p "$d";
        (set -x; sudo mount -t cifs //${CIFSHOST:-192.168.0.52}/"$x" "$d" -o uid=`id -u`,gid=`id -g`${USERNAME:+,username=$USERNAME${PASSWORD+,password=$PASSWORD}} || rmdir "$d"
)
    done
}
