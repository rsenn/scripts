#!/bin/bash


NL="
"
TS="	"
IFS="${NL}${TS}"
GRUB_CFG_EXPR="^\s*(kernel|linux|linux16|linuxold|linuxefi|initrd|title|label)\s"
GRUB_MULTILINE_EXPR="/^\s*text/ { :lp; N; /endtext\s*$/! b lp; s,\s*\\n,\\\\n,g  }"



main()
{

  ARGS="$*"

  if [ -z "$ARGS" ]; then
    MOUNTPOINTS=`mountpoints |sort -u`  
    ARGS=`(for MNT in $MOUNTPOINTS; do ls -1 -d "$MNT"/{boot,efi,BOOT,EFI,grub,GRUB}; done) 2>/dev/null|sort -u`  

  fi

  set -- $ARGS
 
  IGNORE_EXTS="*.mod
*.efi
*.icns
*.mod
*.png
*.module"
 
  FINDOPTS=` implode "
-or
-iname
" $IGNORE_EXTS` 
  #(set -o noglob ; find "$@" -not -type d -and -not \( -iname $FINDOPTS \) -exec file {} \;)

 (set -x; grep --binary-files=without-match -l -r -E "$GRUB_CFG_EXPR" "$@") |
 (while read -r FILE; do
  set -- $( ${SED-sed} "$GRUB_MULTILINE_EXPR" <"$FILE"|grep -E "$GRUB_CFG_EXPR" "$FILE" | ${SED-sed} "s,^,$FILE:,")
  echo "$*"
  
  if [ $# -gt 3 ]; then
    echo "$FILE"
  fi

   done)




}

mountpoints() 
{ 
    ( require array;
    MOUNTPOINTS=;
    for MNT in $(awk '{ print $2 }' /proc/mounts);
    do
        array_push_unique MOUNTPOINTS "$MNT";
    done;
    echo "$MOUNTPOINTS" )
}

implode() 
{ 
    ( S="$1"; shift; unset DATA;
    for LINE; do
        DATA="${DATA+$DATA$S}$LINE";
    done;
    echo "$DATA" )
}

. require.sh

main "$@"

