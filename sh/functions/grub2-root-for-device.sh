grub2-root-for-device()
{
    ( [ ! -b "$1" ] && exit 2;
    ROOT=$(grub2-device-string "$1");
    echo "set root='$ROOT'" )
}
