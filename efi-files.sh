#!/bin/bash

MODE=1
while :; do
	case "$1" in
		 -2) MODE=2; shift ;;
     -x) EXCLUDE="${EXCLUDE:+$EXCLUDE
}$2"; shift 2 ;;
     -x*) EXCLUDE="${EXCLUDE:+$EXCLUDE
}${2#-x}"; shift ;;
     -e|-efi|--efi) EFI="efi" ;;

		 *) break ;;
	esac
done

. require.sh


require util
require var 
require str

. $HOME/.bash_profile

EFI_FILES=`
  locate -i -e -r '\.efi$'|
		while read -r FILE; do file "$FILE"; done|
		grep :.*EFI|
		cut -d: -f1|
		grep -v /tools/
`

for EFI_FILE in $EFI_FILES; do

  FS=`detect-filesystem "$EFI_FILE"` 
  TYPE=` file - <"$EFI_FILE" |${SED-sed} 's,^[^:]*:\s*,,'` 
  DEV=` device-of-file "$EFI_FILE"` 
  MNT=`  mountpoint-for-file "$EFI_FILE" ` 
  GRUB_DEV=` grub-device-string "$DEV" ` 
  GRUB2_DEV=` grub2-device-string "$DEV" ` 


  RELATIVE_FILE=${EFI_FILE#$MNT}
  PTABLE_TYPE=` partition-table-type "$DEV" ` 


   case "$PTABLE_TYPE" in
     mbr) PART_MODULE="part_msdos" ;;
     *) PART_MODULE="part_${PTABLE_TYPE}" ;;
   esac

	case $TYPE in
    *"DLL"*) continue ;; 
		*"EFI application"* | *"EFI binary"*) ;;
		*) continue ;;
	esac
  TYPE=${TYPE%","*}
  case "$TYPE" in
    *"("*) TYPE=${TYPE#*"("}; TYPE=${TYPE//") "/", "}  ;;
  esac
  TYPE=${TYPE%%"("*}
  TYPE=` str_trim "$TYPE"` 
  TYPE=${TYPE%" "}
  TYPE=${TYPE%","}

  case "$FS" in
    hfsplus) FS_MODULE="hfs" ;;
    *) FS_MODULE="$FS" ;;
  esac

  if [ "$EXCLUDE" ] && matchany "$EFI_FILE" $EXCLUDE ; then
    continue 
  fi

  var_dump EFI_FILE DEV MNT TYPE FS FS_MODULE GRUB_DEV GRUB2_DEV RELATIVE_FILE PTABLE_TYPE PART_MODULE  1>&2
echo 1>&2
  case "$MODE" in
    1)
      echo "title EFI $RELATIVE_FILE ($TYPE)"
      echo "  root $GRUB_DEV"
      echo "  chainloader $RELATIVE_FILE"
      echo
    ;;
    2)
      echo "menuentry 'EFI $RELATIVE_FILE ($TYPE)' {"
      echo "  insmod $PART_MODULE"
      echo "  insmod $FS_MODULE"
      echo "  set root=$GRUB2_DEV"
      echo "  chainloader $RELATIVE_FILE"
      echo "}"
      echo 
    ;;
  esac
echo
done
