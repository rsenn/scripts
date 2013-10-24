output-boot-entry()
{
 (
  [ -z "$FORMAT" ] && FORMAT="$1"
  case "$FORMAT" in
    grub4dos) 
       echo "title "${TITLE//"
"/"\\n"}
         [ "$CMDS" ] && echo -e "CMDS${TYPE:+ ($TYPE)}:\n$CMDS"| sed 's,^,#,'
       if [ "$KERNEL" ]; then
        echo "kernel $KERNEL"
       [ "$INITRD" ] && echo "initrd $INITRD" 
       fi
       
    ;;
    grub2)
       echo "menuentry \"$TITLE\" {"
       echo "  linux $KERNEL"
       echo "  initrd $INITRD"
       echo "}"
    ;;
    syslinux|isolinux)
       [ -z "$LABEL" ] && LABEL=$(canonicalize -m 12 -l "$TITLE")
       echo "label $LABEL"
       echo "  menu label ${TITLE%%
*}"
       if [ "$KERNEL" ]; then
         set -- $KERNEL
         echo "  kernel $1"
         shift
         [ "$INITRD" ] && set -- initrd="$INITRD" "$@"
         [ $# -gt 0 ] &&
         echo "  append" $@
       fi
       
       if [ "$CMDS" ]; then
         echo -e "CMDS${TYPE:+ ($TYPE)}:\n$CMDS" |sed 's,^,  #,'
         fi
       
     ;;
  esac
  echo
 )
}