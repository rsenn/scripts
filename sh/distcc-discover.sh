#!/bin/bash

MY_UID=`id -u`           # determine privileges
MY_NAME=`basename "$0"`  # script name
MY_DOMAIN=`hostname -d`  # domain name

# When not root, do connection-based scan, otherwise do stealth-scan
#SCAN_TYPE='-sT --unprivileged'
SCAN_TYPE='-sT'

test "$MY_UID" = 0 && SCAN_TYPE='-sS --privileged' 

# distccd defaults
DEFAULT_PORT=3632

# Set target networks
SCAN_PORTS="-p$DEFAULT_PORT"
#SCAN_TARGETS="212.103.64.0/24 212.103.74.0/24"


IP_ADDR=`ip addr|sed -n 's,.*inet \([^ /]*\).*,\1,p'`

SCAN_TARGETS="${IP_ADDR%.*}.1-255"

# Set remaining settings

SCAN_PING='-P0'      # no ping-check
#SCAN_OUTFMT='-oG -'      # grep-able
#SCAN_RESOLVE='-n'        # don't do any reverse lookupts
#SCAN_LOG='--log-errors'  # log error messages

exec 9>&2
exec 2>&1

# Do the scan
{ 
#  PS4="$MY_NAME: executing "; set -x
  
 set --  nmap $SCAN_TYPE $SCAN_PING $SCAN_RESOLVE $SCAN_OUTFMT $SCAN_LOG --open \
       $SCAN_PORTS $SCAN_TARGETS 

  [ -n "$DEBUG" ] && echo + "$@" 1>&9
 "$@" 
} >nmap-output.log 


pushv () 
{ 
    eval "shift;$1=\"\${$1:+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

{
  DISTCC_HOSTS=
  IFS=$' \t\r\n'

  while read -r LINE; do
     case "$LINE" in
       *"for "*) ip=${LINE##*"for "} ;;
       *[0-9]/*open*) port=${LINE%%/*} 
         ip=${ip#[!0-9.]}
         ip=${ip#[!0-9.]}

     pushv DISTCC_HOSTS $ip:$port
         ;;
     esac
   done <nmap-output.log


  echo "DISTCC_HOSTS=\"$DISTCC_HOSTS\"" | tee distcc.hosts
} 
