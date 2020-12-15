cols() {
  column -c ${COLUMNS:-`tput cols`}
}
