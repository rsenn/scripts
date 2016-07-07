win-set-environment () 
{ 
 ( unset VAR KEY GLOBAL  PRINT CMD
 CMD='reg add "$KEY" /v "$VAR" /t REG_SZ /d "$DATA" /f'
  while :; do
    case "$1" in
      -p | --print) CMD="echo \"${CMD//\"/\\\"}\""; shift ;;
      -g | --global | --local*machine*) GLOBAL=true; shift ;;
      *) break ;;
    esac
  done
  [ "$GLOBAL" = true ] &&   KEY='HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' || KEY='HKCU\Environment'
  
  for VAR ; do 
  (case "$VAR" in
     *=*) DATA=${VAR#*=}; VAR=${VAR%%=*} ;;
     *) eval "DATA=\${$VAR}" ;;
   esac
  
    eval "$CMD") || exit $?
  done 
    )
}
