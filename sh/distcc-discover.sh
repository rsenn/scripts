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

# Do the scan
time { 
#  PS4="$MY_NAME: executing "; set -x
  
 set --  nmap $SCAN_TYPE $SCAN_PING $SCAN_RESOLVE $SCAN_OUTFMT $SCAN_LOG --open \
       $SCAN_PORTS $SCAN_TARGETS 

 echo + "$@" 1>&2
 "$@"
} | {
  DISTCC_HOSTS=
  ${SED-sed} -u \
      -e 's,\s*Host:\s\+\([.0-9]\+\)\s\+(\([^)]*\))\s*,\1\t\2\t,' \
      -e 's,\s*Status:\s\+\([^\s]\+\)\s*,\\t,' \
      -e 's,\s*Ports:\s\+\(.*\)$,\t\1\t,' | 
  while IFS=',	,
'; read ip hostname ports
  do
    case $ip in
      \#*) 
        echo $ip $hostname $ports 1>&2 
        continue 
      ;;
    esac

    set -- `echo "$ports" | ${SED-sed} 's|,\s*|\n|g' | ${SED-sed} 's|/*$||'`
    
    while test "$#" -gt 0; do
      if test -n "$hostname"; then
        HOST="${hostname%.$MY_DOMAIN}"
      else
        HOST="$ip"
      fi

      if test "$1" = "$DEFAULT_PORT"; then
        PORT=
      else
        PORT="$1"
      fi

      DISTCC_HOSTS="${DISTCC_HOSTS:+$DISTCC_HOSTS }$HOST${PORT:+":$PORT"}"
    done
  done

  echo "DISTCC_HOSTS=\"$DISTCC_HOSTS\"" | tee distcc.hosts
}

