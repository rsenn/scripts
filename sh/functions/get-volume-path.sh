get-volume-path() {
  (for ARG; do
  if [ -e /dev/disk/by-label/"$ARG" ]; then
      DEV=/dev/disk/by-label/"$ARG" 
    LABEL=${DEV##*/}
    DEV=$(realpath "$DEV")
  fi


   done)

