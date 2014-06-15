#!/bin/sh

: ${USERNAME=${1?"require username"}}
: ${PASSWORD=${2?"require password"}}
#: ${UNIXTIME=${3-`date +%s`}}
UNIXTIME=`date +%s`

shift 2

IFS=" ""
"
[ "$#" -eq 0 ] && set -- ${CHECKPW-checkpassword id}
#: ${CHECKPW=${*-"checkpassword true"}}
#: ${PROGRAM=${5-"id"}}

printf "%s\0%s\0%s\0" "$USERNAME" "$PASSWORD" "$UNIXTIME" | "$@" 3<&0
