#!/bin/bash

exec_bin()
{
  (IFS=" $IFS"; CMD="$*"
  [ "$DEBUG" = true ] &&  echo "+ $CMD" 1>&2 
  exec "$@")
}

eval_bin()
{
  (IFS=" $IFS"; CMD="$*"
  [ "$DEBUG" = true ] &&  echo "+ $CMD" 1>&2 
  eval "$*")
}

decode_ls_lR()
{
 (IFS=" "
  N=9
  
  while [ "$1" ]; do
    case "$1" in
      -n | --num-cols | --num) N="$2" ; shift 2 ;; -n=* | --num-cols=* | --num=*) N="${1#*=}"; shift ;; -n*) N="${1#-n}" ; shift ;;
      -p | --prefix) PREFIX="$2"; shift 2 ;; -p=* | --prefix=*) PREFIX="${1#*=}" ; shift ;; -p*) PREFIX="${1#-p}"; shift ;;
      *) break ;;
    esac
  done
  
  ARG="$*"
  
  #if [ "$N" = 6 ]; then
  #  VARS="TYPE DATE TIME SIZE UNIT FILE"
  #else
  #  VARS="MODE LINKS USER GROUP SIZE MONTH DAY TIME FILE"
  #fi
  #DIR=/
  while read -r LINE; do
    set -- $LINE
    case "$LINE" in
            "") continue ;;
      *:)
        DIR="${LINE%:}"
        echo "New directory $DIR" 1>&2
        continue
        ;;
      "file "* | "dir "* | "link "*)
         TYPE="$1" DATE="$2" TIME="$3" SIZE="$4" UNIT="$5"
         shift 5
         FILE="$*"
         ;;
      ??????????" "*)
         MODE="$1" LINKS="$2" USER="$3" GROUP="$4" SIZE="$5" MONTH="$6" DAY="$7" TIME="$8"
         shift 8
         FILE="$*"
        ;;
    esac
  
    case "$FILE" in
           *" -> "*) TARGET=${FILE#*" -> "}; FILE=${FILE%%" -> "*} ;;
     */) ;;
     *) case "$TYPE" in
          dir) FILE="$FILE/" ;;
        esac
   ;;
    esac
  
  #var_dump PREFIX DIR FILE
       echo "${PREFIX:+${PREFIX%/}/}${DIR:+${DIR%/}/}$FILE"
  done)
}
  

list_ftp_lftp()
{
    for ARG; do
   (eval_bin "lftp \"$ARG\" -e \"find ${ARG%/}/; exit\" 2>/dev/null"  
   ) | { 
   VARNAME=LINE 
   read -r LINE
   case "$LINE" in
     *//) VARNAME=LINE%/ ;;
   esac
   [ "$LINE" != "${LINE%//}" ] && VARNAME=LINE%/
   E="echo \"\${$VARNAME}\"; while read -r LINE; do echo \"\${$VARNAME}\"; done"
   eval "$E"
   }
   done
}

list_ftp_ftpls()
{
    for ARG; do
  (HOST=${ARG#*://}
   HOST=${HOST%%/*}
   LOCATION=${ARG#*://$HOST}
   exec_bin ftpls -R "$HOST" "$LOCATION") | decode_ls_lR -n6 -p"${ARG%/}"
   done
}

: ${LFTP=`type lftp 2>/dev/null >/dev/null && echo lftp`}
: ${FTPLS=`type ftpls 2>/dev/null >/dev/null && echo ftpls`}

while :; do
  case "$1"  in
      -t | --type) TYPE="$2" ; shift 2 ;; -t=* | --type=*) TYPE="${1#*=}" ; shift ;; -t*) TYPE="${1#-t}"; shift ;;
      -v | --verbose) VERBOSE=true; shift ;;
      -x | --debug) DEBUG=true; shift ;;
    *) break ;;
  esac
done

if [ -z "$TYPE" ]; then
  if [ "$FTPLS" ]; then
    TYPE=ftpls
  elif [ "$LFTP" ]; then
    TYPE=lftp
  else
    echo "No FTP program such as ftpls/lftp" 1>&2
    exit 2
  fi
fi

for ARG; do
 (case "${TYPE}-${ARG}" in
    ftpls-*http*://*) TYPE=lftp ;;
 esac
  list_ftp_"$TYPE" "$ARG"
  )
done
