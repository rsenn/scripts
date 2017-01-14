get-volume-path() {
  (
  get-volume-list |sed "\\|\s${1}\$| { s|\s${1}\$||; \\|/|! { s|\$|/| }; p }" -n 
#  RF="[^ ]\+\s\+"
#  for ARG; do
#  df "$(  get-volume-list |sed -n "\\|\\s$ARG\$| { s|\s.*||; p }")" |sed "1d; s|^${RF}${RF}${RF}${RF}${RF}||"
#
#
#   done
)
}

