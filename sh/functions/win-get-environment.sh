win-get-environment () 
{ 
 ( unset S VAR KEY GLOBAL 
  while :; do
    case "$1" in
      -m | --mixed) MIXED=true; shift ;;
      -s=* | --separator=*) S=${1#*=}; shift ;;
      -s*) S=${1#-s}; shift ;;
      -s | --separator) S=$2; shift 2 ;;
      -g | --global | --local*machine*) GLOBAL=true; shift ;;
      *) break ;;
    esac
  done
EXPR="s,.*REG_SZ\s\+\(.*\),\1, ; ${S+s|;|${S:-\\n}|g}"
[ "$MIXED" = true ] && EXPR="$EXPR; s|\\\\|/|g"
EXPR="/REG_SZ/ { $EXPR; p }"

#echo "EXPR=$EXPR" 1>&2
  [ "$GLOBAL" = true ] &&   KEY='HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' || KEY='HKCU\Environment'
  [ $# -le 0 ] && set -- PATH
  
  for VAR ; do 
    reg query "$KEY" /v "$VAR"
  done | sed -n "$EXPR"
    )
}
