cols() {
  command column -c ${COLUMNS:=`tput cols`}
}
