icacls-r() {
 (while :; do
    case "$1" in
      -u | --user) NTUSER="$2"; shift 2 ;;  -u=* | --user=*) NTUSER=${1#*=}; shift ;; -u*) NTUSER=${1#-?}; shift ;;
      -e | --everyone) NTUSER="Everyone"; shift ;;
      -r | --reset) RESET="true"; shift ;;
      -f | --full) FULL="true"; shift ;;
      -o | --own*) TAKEOWN="true"; shift ;;
      -c | --cmd) CMD="true"; shift ;;
      -p | --print) PRINT="true"; shift ;;
      -s | --separator) SEP="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  if [ "$CMD" = true ]; then
    : ${SEP=" & "}
    NUL="nul"
  fi
  : ${ICACLS=icacls}
  
  if [ "$FULL" ]; then
    PERM="F"
  else
	PERM="(OI)(CI)M"
  fi
	
  #DEFAULT_USER="*S-1-0"          # Null Authority
  #DEFAULT_USER="*S-1-0-0"        # Nobody
  #DEFAULT_USER="*S-1-1"          # World Authority
  #DEFAULT_USER="*S-1-1-0"        # Everyone
  #DEFAULT_USER="*S-1-2"          # Local Authority
  #DEFAULT_USER="*S-1-3"          # Creator Authority
  DEFAULT_USER="*S-1-3-0"        # Creator Owner
  #DEFAULT_USER="*S-1-3-1"        # Creator Group
  #DEFAULT_USER="*S-1-3-2"        # Creator Owner Server
  #DEFAULT_USER="*S-1-3-3"        # Creator Group Server
  #DEFAULT_USER="*S-1-4"          # Nonunique Authority
  #DEFAULT_USER="*S-1-5"          # NT Authority
  #DEFAULT_USER="*S-1-5-1"        # Dialup
  #DEFAULT_USER="*S-1-5-2"        # Network
  #DEFAULT_USER="*S-1-5-3"        # Batch
  #DEFAULT_USER="*S-1-5-4"        # Interactive
  #DEFAULT_USER="*S-1-5-6"        # Service
  #DEFAULT_USER="*S-1-5-7"        # Anonymous
  #DEFAULT_USER="*S-1-5-8"        # Proxy
  #DEFAULT_USER="*S-1-5-9"        # Enterprise Controllers
  #DEFAULT_USER="*S-1-5-10"       # Principal Self (or Self)
  #DEFAULT_USER="*S-1-5-11"       # Authenticated Users
  #DEFAULT_USER="*S-1-5-12"       # Restricted Code
  #DEFAULT_USER="*S-1-5-13"       # Terminal Server Users
  #DEFAULT_USER="*S-1-5-18"       # Local System
  #DEFAULT_USER="*S-1-5-32-544"   # Administrators
  #DEFAULT_USER="*S-1-5-32-545"   # Users
  #DEFAULT_USER="*S-1-5-32-546"   # Guests
  #DEFAULT_USER="*S-1-5-32-547"   # Power Users
  #DEFAULT_USER="*S-1-5-32-548"   # Account Operators
  #DEFAULT_USER="*S-1-5-32-549"   # Server Operators
  #DEFAULT_USER="*S-1-5-32-550"   # Print Operators
  #DEFAULT_USER="*S-1-5-32-551"   # Backup Operators
  #DEFAULT_USER="*S-1-5-32-552"   # Replicators

  GRANT="${NTUSER-$DEFAULT_USER}:$PERM"
  
  if [ "$RESET" = true ]; then
    COMMAND="/RESET"
  else
    COMMAND="/grant \"$GRANT\""
  fi
  
  case "$ICACLS" in
    *icacls*) ICACLS_ARGS="/inheritance:e /T /Q /C $COMMAND"  ;;
    *cacls*) ICACLS_ARGS="/T /C $COMMAND" ;;
    *xcacls*) ICACLS_ARGS="/T /C /Q $COMMAND" ;;
   esac
   
   IFS="$IFS "
  for ARG; do
   (type realpath 2>/dev/null >/dev/null && ARG=$(realpath "$ARG")
   ARG=$(${PATHTOOL:-cygpath}${PATHTOOL:+
-w} "${ARG%[/\\]}")
    ARG=${ARG%[\\/]}
    [ -d "$ARG" ] && D="-R -D Y "
    ARG="\"$ARG\""
    
    EXEC="${ICACLS:-icacls} $ARG ${ICACLS_ARGS}"
    [ "$TAKEOWN" = true ] && EXEC="takeown ${D}-F $ARG >${NUL:-/dev/null}${SEP:-; }$EXEC"
#    [ "$CMD" = true ] && EXEC="cmd /c \"${EXEC//\"/\\\"}\""
    [ "$PRINT" = true ] && { EXEC=${EXEC//\\\"/\\\\\"}; EXEC="echo \"${EXEC//\"/\\\"}\""; }
    [ "$DEBUG" = true ] && echo "+ $EXEC" 1>&2
    ${E:-eval} "$EXEC")
  done)
}
