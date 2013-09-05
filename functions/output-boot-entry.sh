output-boot-entry()
{
 (
  [ -z "$FORMAT" ] && FORMAT="$1"
  case "$FORMAT" in
    grub4dos) 
       echo "title $TITLE"
       echo "kernel $KERNEL"
       echo "initrd $INITRD"
    ;;
    grub2)
       echo "menuentry \"$TITLE\" {"
       echo "  linux $KERNEL"
       echo "  initrd $INITRD"
       echo "}"
    ;;
    syslinux|isolinux)
       echo "label $LABEL"
       echo "  menu label $TITLE"
       echo "  kernel ${KERNEL%%' '*}"
       echo "  append initrd=$INITRD ${KERNEL#*' '}"
       
     ;;
  esac
  echo
 )
}