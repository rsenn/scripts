get-volume-path() {
  (
  RF="[^ ]\+\s\+"
  for ARG; do
  df "$(  get-volume-list |sed -n "\\|\\s$ARG\$| { s|\s.*||; p }")" |sed "1d; s|^${RF}${RF}${RF}${RF}${RF}||"


   done)
}

