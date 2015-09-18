vs2vc() {
 (for ARG; do
   case "$ARG" in
     2005) echo 8.0 ;; 
     2008) echo 9.0 ;; 
     2010) echo 10.0 ;; 
     2012) echo 11.0 ;; 
     2013) echo 12.0 ;; 
     2015) echo 14.0 ;; 
     *) echo "No such Visual Studio version: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}