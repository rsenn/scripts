#!/bin/bash

IFS="
"
while :; do
  case "$1" in
    -s | --show-size | --*size*) SHOW_SIZE=true; shift ;;
    -r | --rename | --*rename*) DO_RENAME=true; shift ;;
    -n | --derive-name | --*name*) DERIVE_NAME=true; shift ;;
    -p | --print-only | --*print*) PRINT_ONLY=true; shift ;;
    -f | --force) FORCE=true; shift ;;
    *) break ;;
  esac
done

ctor_listfiles()
{
 (DIR= FILE= O=
  set -- $CTOR
  while [ "$1" != "FILES INFO" ]; do
    shift
    [ $# -eq 0 ] && exit 2
  done
  shift
  while [ $# -gt 0 ]; do
    LINE="$1"
    shift
    case "$LINE" in
      "Directory: "*)
        DIR=${LINE#"Directory: "}
      ;;
      "<"*">"*" ["*"]"*)
        N=${LINE#"<"}; N=${N%">"*}
        LINE=${LINE#*">"}
        while [ "${LINE:0:1}" = " " ]; do LINE=${LINE#" "}; done
        FILE=${LINE%" ["*"]"*}
        LINE=${LINE##*" ["}
        SIZE=${LINE%"]"*}

       eval "O=\"\${O:+$O
}${OUTPUT}\""
      ;;
    esac
  done
  [ "$O" ] && echo "$O") || return $?
}

escape() 
{ 
  local s="$1";
  s=${s//"\\"/"\\\\"};
  s=${s//'"'/'\"'};
  echo "$s"
}
ARGS="$*"
OUTPUT='${DIR:+$DIR/}${FILE}'
CMD='ctor_listfiles'


[ "$SHOW_SIZE" = true ] && OUTPUT="$OUTPUT [\$SIZE]"

if [ "$DERIVE_NAME" = true -o "$DO_RENAME" = true ]; then
  CMD="$CMD | sed s,/.*,, | uniq"
 if [ "$DO_RENAME" = true ] ; then
    CMD="mv -vf -- \"\$ARG\" \"\$($CMD).torrent\""
    [ "$PRINT_ONLY" = true ] && CMD="echo \"$(escape "$CMD")\""
fi
fi


for ARG in $ARGS; do
  CTOR=$(ctorrent -x "$ARG")
  if ! [ "$CTOR" ] || ! eval "$CMD"; then
    if [ "$FORCE" != true ]; then
      echo "Failed reading torrent '$ARG'" 1>&2
      exit $?
    fi
  fi

done
