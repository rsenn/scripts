XCODE_APP=/Applications/Xcode.app

xcode() {
  (CMD='open -a "\$XCODE_APP" "\$@" &'
  [ "$DEBUG" = true ] && eval "echo \"${CMD//\\\$/\$}\" 1>&2"
   eval "$CMD")
}
