pathremove() {
  old_IFS="$IFS"
  IFS=":"
  RET=1
  unset NEWPATH

  for DIR in $PATH; do
    for ARG; do
      case "$DIR" in
        $ARG) RET=0; continue 2 ;;
      esac
    done
    NEWPATH="${NEWPATH+$NEWPATH:}$DIR"
  done

  PATH="$NEWPATH"
  IFS="$old_IFS"
  unset NEWPATH old_IFS
  return $RET
}
