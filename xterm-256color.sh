
case $TERM in
  rxvt* | xterm* | mrxvt*)
    if test "`TERM=xterm-256color; tput colors`" = 256; then
      TERM=xterm-256color
    fi
 ;;
esac
