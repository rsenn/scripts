
# Have an X11 display set?
if test -n "$DISPLAY"; then

  if test -z "`pgrep browser-history`"; then
    setsid browser-history 
  fi

fi

