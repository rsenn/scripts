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

process_lines() {
    LINENO=0
    while read -r LINE ; do 
       
        LINENO=$((LINENO+1))

       case "$LINE" in
           "PACKAGE NAME:"*) 
                FILENAME=${LINE#PACKAGE NAME:  }
                #echo "FILENAME=$FILENAME" 1>&2
                #NAME=${FILENAME%%-[0-9]*}
            ;;
           "Package: "* | PACKAGE\ NAME*) NAME=${LINE#Package: }
           ;;
           "Filename: "*) 
               FILENAME=${LINE#Filename: }
               FILENAME=${FILENAME#./}
               LOCATION=${ARG%%/ubuntu/*}/ubuntu/${FILENAME%/*}
               FILENAME=${FILENAME##*/}
           ;;

       "PACKAGE LOCATION"*)
           LOCATION=${LINE#PACKAGE LOCATION:}
            LOCATION=${ARG%/*}/${LOCATION#*./}
           ;;

           "") [ "$NAME" ] && {
            #: $((N++)); output_num "$N"
               echo "$LOCATION/$FILENAME"
           } #|| echo "Line $LINENO: $LINE"
           ;;

       *": "*)
            NAME=${LINE%%:*}
        ;;
       esac
       L=${LINE%%:*}

            #var_dump L NAME FILENAME LOCATION
       
       #echo "NAME=$NAME LINE=$LINE" 1>&2

    done
}

read_package_lists() {
 
  output_num() { echo -n -e "\r     \r$1" 1>&2;  }  
  GET='curl -s "$ARG"'

   . require.sh; require var; var_s=' '

  for ARG; do
   (case "$ARG" in
        */slacky/*)    ;;
        *.bz2) GET="$GET | bzcat" ;;
        *.gz) GET="$GET | zcat " ;;
    esac
   
    [ "$DUMP" = true ] || GET="$GET | process_lines"

    ( [ "$DEBUG" = true ] && eval "echo \"GET='${GET//\"/\\\"}'\" 1>&2"; eval "$GET") || exit $?

  ) || return $?; done
}

pkg_get() {
  IFS="
"
  while :; do
    case "$1" in
      -h | -\? | --help) usage; exit 0 ;;
      -x | --debug) DEBUG=true; ;; 
      -d | --dump) DUMP=true; ;; 
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
