parse-boot-entry()
{
  TYPE= TITLE= KERNEL= INITRD=

  while :; do
    read -r LINE || return $?
    if [ -z "$TYPE"  ]; then
	    case "$LINE" in
	      *menuentry*{*) TYPE=grub; TITLE=${LINE#*\"}; TITLE=${TITLE%\"*\{} ;;
	      *title\ *) TYPE=oldgrub; TITLE=${LINE#title\ *} ;;
	      *menu*label* | *MENU*LABEL*) TYPE=syslinux; TITLE=${LINE#*MENU}; TITLE=${TITLE#*LABEL}; TITLE=${TITLE#*label}; TITLE=${TITLE/^/} ;;
	      *) continue ;; 
	    esac
	    TITLE=${TITLE#' '}
      else
        case "$TYPE" in
           syslinux)
              case "$LINE" in 
                *kernel\ *) KERNEL="${LINE#*kernel\ }" ;;
                *append\ *) 
                   IFS="$IFS "
                   set -- ${LINE#*append\ }
                   for ARG; do
                     case "$ARG" in 
                       initrd=*) INITRD="${ARG#*=}" ;;
                       *) KERNEL="${KERNEL:+$KERNEL }$ARG" ;;
                     esac
                   done
                    ;;
                *menu\ *) return 0 ;;
              esac 
           ;;
           grub)
              case "$LINE" in 
                *linux*\ *) KERNEL="${LINE#*linux*\ }" ;;
                *initrd*\ *) INITRD="${LINE#*initrd*\ }" ;;
                *menuentry*{*) return 0 ;;
              esac 
           ;;
           oldgrub)
              case "$LINE" in 
                *kernel*\ *) KERNEL="${LINE#*kernel*\ }" ;;
                *initrd*\ *) INITRD="${LINE#*initrd*\ }" ;;
                *title\ *) return 0 ;;
              esac 
           ;;
         esac
      fi
  done
}
