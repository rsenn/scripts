vs2vc() {
 (for ARG; do
   case "$ARG" in
     8 | 8.0 | 8.00) echo 2005 ;;
     9 | 9.0 | 9.00) echo 2008 ;;
     10 | 10.0 | 10.00) echo 2010 ;;
     11 | 11.0 | 11.00) echo 2012 ;;
     12 | 12.0 | 12.00) echo 2013 ;;
     14 | 14.0 | 14.00) echo 2015 ;;
     *) echo "No such Visual Studio version: $ARG" 1>&2; exit 1 ;;
   esac
  done)
}