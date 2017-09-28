#!/bin/bash


addsuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "$LINE$SUFFIX"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}



get_package_lists() {

  case "$1" in
    slacky) 
        set -- $(dlynx.sh http://slackware.org.uk/slacky/|grep /slacky/.*/|addsuffix PACKAGES.TXT ) ;;
    ubuntu) 
   set -- http://ch.archive.ubuntu.com/ubuntu/dists/trusty{,-updates,-security,-backports,-proposed}/{main,universe,multiverse,restricted}/binary-amd64/Packages.bz2 ;;

  esac
  echo "$*"
}

read_package_lists() {

  for ARG; do
    (GET='curl -s "$ARG"'
    case "$ARG" in
      */slacky/*) 

    ;;
    *.bz2) GET="$GET | bzcat" ;;
    *.gz) GET="$GET | zcat " ;;
    esac

    output_num() {
       echo -n -e "\r     \r$1" 1>&2
    }   
    ( [ "$DEBUG" = true ] && eval "echo \"GET='${GET//\"/\\\"}'\" 1>&2"; eval "$GET")| {
    N=0
    while read -r LINE; do 
#echo "$LINE"
       P=${LINE%%": "*}
       V=${LINE##*": "}
       V=${V#" "}
       V=${V#" "}
       V=${V#" "}
      . require.sh; require var 
       case "$P" in
           "Package" | "PACKAGE NAME") NAME="$V" ;;
           "Filename") 
               FILENAME="${V#./}"
               LOCATION="${ARG%%/ubuntu/*}/ubuntu/${FILENAME%/*}"
               NAME=${FILENAME##*/}
               
               : var_dump LOCATION FILENAME  NAME
           ;;

           "PACKAGE LOCATION") 
               LOCATION="${ARG%/*}/${V#./}"
           ;;

           "") [ "$NAME" ] && {
            #: $((N++)); output_num "$N"
               echo "$LOCATION/$NAME"
           } || echo "$P"
           ;;

       esac

    done
  }

  )
  done

}

pkg_get() {


  IFS="
"
  while :; do
    case "$1" in
      -h | -\? | --help) usage; exit 0 ;;
      -x | --debug) DEBUG=true; ;; 
      *) break ;;
    esac
    shift
  done

  DIST="$1"
  [ -z "$DIST" ] && DIST="slacky"
  
  set -- $(get_package_lists "$DIST")
  echo "Package lists:" "$@" 1>&2
   
  read_package_lists "$@"
}

pkg_get "$@"
