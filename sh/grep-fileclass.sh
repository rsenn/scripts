#!/bin/bash

while :; do
  case "$1" in
    -c) COMPLETE=true; shift ;;
    -x) DEBUG=true; shift ;;
  *) break ;;
esac
done

push()
{
  OUTPUT="${OUTPUT+$OUTPUT${IFS%%${IFS#?}}}$*"
}

for CLASS; do
  case "$CLASS" in
    bin*|exe*|prog*)  push "\."{"exe","msi","dll"} ;;
    archive*) push "\."{"7z","rar","tar\.bz2","tar\.gz","tar\.xz","tar","tar\.lzma","tbz2","tgz","txz","zip"} ;;
    audio*) push "\."{"aif","aiff","flac","m4a","m4b","mp2","mp3","mpc","ogg","raw","rm","wav","wma"} ;;
    fonts*) push "\."{"bdf","flac","fon","m4a","m4b","mp3","mpc","ogg","otf","pcf","rm","ttf","wma"} ;;
    image*) push "\."{"bmp","cin","cod","dcx","djvu","emf","fig","gif","ico","im1","im24","im8","jin","jpeg","jpg","lss","miff","opc","pbm","pcx","pgm","pgx","png","pnm","ppm","psd","rle","rmp","sgi","shx","svg","tga","tif","tiff","wim","xcf","xpm","xwd"} ;;
    incompl*|part*) push "\."{"\*\.!??","\*\.part","INCOMPL\*","\\\[/\\\]INCOMPL\[^/\\\]\*","\\\.!??","\\\.part"} ;;
    music*) push "\."{"aif","aiff","flac","m4a","m4b","mp3","mpc","ogg","rm","voc","wav","wma"} ;;
    package*|pkg*) push "\."{"deb","rpm","tgz","txz"} ;;
    patch*|diff*) push "\."{"diff","patch)[^/]*" ;;
    script*) push "\."{"bat","cmd","py","rb","sh"} ;;
    software*) push "\."{"\*\.msi","\*install\*\.exe","\*setup\*\.exe","\.msi","deb","exe","install\*\.exe","msi","rpm","setup\*\.exe"} ;;
    source*) push "\."{"c","cpp","cxx","h","hpp","hxx"} ;;
    video*) push "\."{"3gp","avi","f4v","flv","m2v","mkv","mov","mp4","mpeg","mpg","ogm","vob","wmv"} ;;
    vmware*|vbox*|virt*|v*disk*) push "\."{"vdi","vmdk","vhd","qed","qcow","vhdx","hdd"} ;;
    '') ;;
    *) echo "No such class '$CLASS'." 1>&2; exit 2 ;;
  esac
  shift
done

[ "$COMPLETE" != true ] && TRAIL="[^/]*"


[ -z "$OUTPUT" ] && OUTPUT="."

CMD="grep -iE \"(\$(IFS=\"| \$IFS\"; set \$OUTPUT; echo \"\$*\"))\${TRAIL}\\\$\"  \"\$@\""
eval "$CMD"

