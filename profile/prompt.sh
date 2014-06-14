HAVE_256_COLORS=false

case "$TERM" in
  *256color*) HAVE_256_COLORS=true ;;
  Eterm*|gnome*|konsole*|putty*|rxvt*|rxvt-unicode*|screen*|st*|vte*|xterm*) TERM="$TERM-256color" HAVE_256_COLORS=true ;;
  *)
    if [ "$(tput colors)" -ge 256 ] 2>/dev/null; then
      HAVE_256_COLORS=true
    fi
  ;;
esac

if [ "$HAVE_256_COLORS" = true ]; then
  #C1='161' C2='106' C3='178'
  #C1=44 C2=110 C3=225
  #C1=108 C2=67 C3=106
  #C1=235 C2=129 C3=148
  #C1=169 C2=49 C3=98
  #C1=121 C2=119 C3=40
  #C1=204 C2=69 C3=204
  #C1=196 C2=171 C3=50
  C1=84 C2=187 C3=132
  new-prompt() {
    PROFILE=/etc/profile.d/prompt.sh
    LINE="C1=${1-$((RANDOM % (256 - 32) + 16))} C2=${2-$((RANDOM % (256 - 32) + 16))} C3=${3-$((RANDOM % (256 - 32) + 16))}"
    sudo sed -i "/^C[1-3]=/ s,^,#," $PROFILE
  #C1=37 C2=217 C3=76
    sudo sed -i "/^new-prompt()/ i\
  $LINE
  " $PROFILE
    . $PROFILE
  }

  PS1='\[\033[38;5;${C1}m\]\u\[\033[0m\]@\[\033[38;5;${C2}m\]\h\[\033[0m\]:\[\033[1m\](\[\033[0m\]\[\033[38;5;${C3}m\]\w\[\033[0m\]\[\033[1m\])\[\033[0m\] \$ '
else
  PS1='\u@\h:\w \$ '
fi
