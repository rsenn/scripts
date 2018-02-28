case $TERM in
  rxvt* |  mrxvt*)
    if test "`TERM=rxvt-256color; tput colors`" = 256; then
      TERM=rxvt-256color
    fi ;;
  screen*)
    if test "`TERM=screen-256color; tput colors`" = 256; then
      TERM=screen-256color
    fi ;;
  xterm*)
    if test "`TERM=xterm-256color; tput colors`" = 256; then
      TERM=xterm-256color
    fi ;;
esac
