# Have an X11 display set?
if [ -n "$DISPLAY" ]; then

  if [ -z "`pgrep browser-history`" ]; then
    setsid "browser-history"
  fi

fi

