mount-sshfs () 
{
 : ${USERNAME="Madeleine"} 
 [ "$#" -le 0 ] && set --  /cygdrive/c:c /cygdrive/c/Users/Madeleine/Downloads:Downloads /cygdrive/c/Users:Users /cygdrive/d:Daten /cygdrive/e:BOOT
    for x ; do
        d=$HOME/mnt/"${x##*:}";
        mkdir -p "$d";
        (set -x; 
				sshfs ${USERNAME:+$USERNAME@}192.168.0.52:${x%:*} "$d"  -o allow_other,reconnect,cache=yes,remember=60,kernel_cache || rmdir "$d")
    done
}
