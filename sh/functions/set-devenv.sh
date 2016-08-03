set-devenv() {
  DEST=${1%/bin*}/bin
  PATH="$DEST:$(explode : "$PATH" |grep -v "$DEST"|implode :)"
}


