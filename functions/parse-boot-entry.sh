parse-boot-entry()
{
  clear-boot-entry() {  TYPE= LABEL= TITLE= KERNEL= INITRD= CMDS=; }
   NL="
"
  unset LINEBUF
  
  getline()
  {
    if [ -n "$LINEBUF" ]; then
      LINE="${LINEBUF%%$NL*}"
      case "$LINE" in
        EOF\ *) T=; clear-boot-entry; return 1 ;;
        *) LINEBUF=${LINEBUF#"$LINE"}; LINEBUF=${LINEBUF#"$NL"} ;;
        esac
    else
      if ! read -r LINE; then
        LINE=""
        LINEBUF="${LINEBUF:+$LINEBUF$NL}EOF $?"
        return 0
      fi
    fi
    OLDIFS="$IFS"
    IFS=" "
    set -- $LINE    
    CMD=$(echo "$1" | tr [:upper:] [:lower:])
    shift
    ARG="$*"
    IFS="$OLDIFS"
  }
  ungetline() { LINEBUF="$LINE${LINEBUF:+$NL$LINEBUF}"; }
  
  while :; do
    getline || return $?
    while [ "$LINE" != "${LINE#' '}" ]; do LINE=${LINE#' '}; done
    [ -z "$LINE" -a -n "$TYPE" ] && return 0
    [ -z "$CMD" ] && continue
    if [ -z "$T"  ]; then
      clear-boot-entry
	    case "$CMD" in
	      menuentry) T=grub; TITLE=${LINE#*\"}; TITLE=${TITLE%\"*\{} ;;
	      title) T=oldgrub; TITLE=${ARG}; TITLE=${TITLE//"\\n"/"$NL"} ;;
	      label) T=syslinux LABEL=${ARG} ;;
#	      menu | *MENU*LABEL*) T=syslinux; TITLE=${LINE#*MENU}; TITLE=${TITLE#*LABEL}; TITLE=${TITLE#*label}; TITLE=${TITLE/^/} ;;
	      *) continue ;; 
	    esac
	    LABEL=${LABEL#' '}
	    TITLE=${TITLE#' '}
    else
    TYPE="$T"
    ARG=${ARG//"\\n"/"$NL"}
    echo "+ CMD=$CMD ARG=$ARG" 1>&2
      case "$T" in
         syslinux)
            case "$CMD" in 
               '#'*) continue ;;
              kernel) KERNEL="${LINE#*kernel\ }" ;;
              append) 
                 IFS="$IFS "
                 set -- ${LINE#*append\ }
                 for ARG; do
                   case "$ARG" in 
                     initrd=*) INITRD="${ARG#*=}" ;;
                     *) KERNEL="${KERNEL:+$KERNEL }$ARG" ;;
                   esac
                 done
                  ;;
              menu)  ARG=${ARG/^/}; TITLE="${TITLE:+$TITLE$NL}${ARG}" ;;
              label)  ungetline; unset T; return 0 ;;
           *) [ -n "$LINE" ] && CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
              
            esac 
         ;;
         grub)
            case "$CMD" in 
               '#'*) continue ;;
              linux) KERNEL="${LINE#*linux*\ }" ;;
              initrd) INITRD="${LINE#*initrd*\ }" ;;
              chainloader|  configfile) CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
              menuentry) ungetline; unset T; return 0 ;;
              *)  CMDS="${CMDS:+$CMDS$NL}$LINE" ;; 
            esac 
         ;;
         oldgrub)
            case "$CMD" in 
               '#'*) continue ;;
              kernel) KERNEL="${LINE#*kernel*\ }" ;;
              initrd) INITRD="${LINE#*initrd*\ }" ;;
              #map*|find*|chainloader*|root*|configfile*|set*|cat*|timeout*|default*|rootnoverify*|savedefault*|terminal*|fallback*|echo*|color*|lock*|write*|splashimage*|iftitle*|graphicsmode*|calc*|menu*|found*)  CMDS="${CMDS:+$CMDS$NL}$LINE" ;; 
              title*) ungetline; unset T; return 0 ;;
              *) [ -n "$LINE" ] && CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
            esac 
         ;;
       esac
      fi
  done
}
