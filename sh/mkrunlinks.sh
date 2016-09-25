#!/bin/sh

find "sv" -type d -not -wholename "*/.*" | 
{
  IFS="./$IFS"

  while read DIR; do
    if [ -x "$DIR/run" -a ! -L "$DIR/supervise" ]; then
      
      set $DIR

      if [ -d "$DIR/supervise" -a -w "/var/run" ]; then
          [ -e "/var/run/$*" ] && rm -rf "/var/run/$*"
        mv -fv "$DIR/supervise" "/var/run/$*"
      fi

      ln -sv "/var/run/$*" "$DIR/supervise"
    fi
  done
}
