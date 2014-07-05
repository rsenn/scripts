case "$TERM" in
  *256color*)
#C1='161' C2='106' C3='178'
#C1=195 C2=50 C3=192
#C1=177 C2=210 C3=49
#C1=181 C2=208 C3=115
#C1=31 C2=22 C3=189
C1=49 C2=211 C3=194
C1='161' C2='106' C3='178'
new_prompt() {
  PROFILE=/etc/profile.d/prompt.sh
  LINE="C1=${1-$((RANDOM % (256 - 32) + 16))} C2=${2-$((RANDOM % (256 - 32) + 16))} C3=${3-$((RANDOM % (256 - 32) + 16))}"
  sudo sed -i "/^C[1-3]=/ s,^,#," $PROFILE
#C1=37 C2=217 C3=76
  sudo sed -i "/^new_prompt()/ i\
$LINE
" $PROFILE
  . $PROFILE
}

PS1='\[\033[38;5;${C1}m\]\u\[\033[0m\]@\[\033[38;5;${C2}m\]\h\[\033[0m\]:\[\033[1m\](\[\033[0m\]\[\033[38;5;${C3}m\]\w\[\033[0m\]\[\033[1m\])\[\033[0m\] \$ '
;;
esac
