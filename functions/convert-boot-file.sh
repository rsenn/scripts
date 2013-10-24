convert-boot-file()
{
  (if [ -e "$1" ]; then
     exec <"$1"
     shift
   fi
   
   [ -z "$FORMAT" ] && FORMAT="$1"
   
   while parse-boot-entry; do
     output-boot-entry "$FORMAT"
   done
   
   
   
   )
}