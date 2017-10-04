decode-ar() {
  : ${HANDLER='7z x -si"$N" -so | tar -t'}
  : ${UNTIL='data.tar*'}

  read -r DATA
  if [ "$DATA" != '!<arch>' ]; then
    exec -<&0 # close stdin
    return 1
  fi
  
  
  while IFS=$' \t\r' read -r N T U G M S; do
    echo "Name: $N Date: $(date --date="@$T" +"%Y%m%d %H:%M:%S") UID: $U GID: $G Mode: $M Size: $S" 1>&2
    S=${S%%[!0-9]*}

     case "$N" in
       $UNTIL)   [ -n "$HANDLER" ] && eval "$HANDLER"; return 0 ;;
    esac

    for I in `seq 1 $((S-1))`; do
      IFS=  read -r -s -d '' -n 1 D
    done

  done
}

