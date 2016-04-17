player-file()
{
  NL="
"
  ( SED_SCRIPT=
  while :; do
          case "$1" in
                  -H|--no*hidden) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|/\\.|d" ; shift ;;
                  -P|--no*proc) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|^/proc|d" ; shift ;;
          -x|--exclude) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|${2//*/.*}|d" ; shift 2  ;;
          -x=*|--exclude=*) P=${1#*=}; SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|^"${P//"*"/".*"}"\$|d" ; shift   ;;
          *) break ;;
          esac
  done
  SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }s| ([^)]*)\$||"
    lsof -n $(pid-args "${@-mplayer}") 2> /dev/null 2> /dev/null 2> /dev/null 2> /dev/null | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto}  -E ' [0-9]+[^ ]* +REG ' | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -vE ' (mem|txt|DEL) ' | cut-lsof NAME |${SED-sed} "$SED_SCRIPT" )
}
