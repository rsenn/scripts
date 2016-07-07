#!/bin/sh

find sv \
  -type d \
  -name "log" \
  -and -not -wholename "*/.*" | 
{
  IFS="./$IFS"

  while read DIR; do
    if [ -x "$DIR/run" ]; then
      set ${DIR%/log}
      shift
      ln -sf "/var/log/$*" "$DIR/main"
    fi
  done
}
