#!/bin/bash

IFS="
"
while :; do
  case "$1" in
    -s | --show-size | --*size*) SHOW_SIZE=true; shift ;;
    -r | --rename | --*rename*) DO_RENAME=true; shift ;;
    -n | --derive-name | --*name*) DERIVE_NAME=true; shift ;;
    -p | --print-only | --*print*) PRINT_ONLY=true; shift ;;
    *) break ;;
  esac
done

ctor_listfiles()
{
 (DIR= FILE=
  set -- $CTOR
  while [ "$1" != "FILES INFO" ]; do
    shift
  done
  shift
  while [ $# -gt 0 ]; do
    LINE="$1"
    shift
    case "$LINE" in
      "Directory: "*)
        DIR=${LINE#"Directory: "}
      ;;
      "<"*">  "*" ["*"]"*)
        N=${LINE#"<"}; N=${N%">"*}
        LINE=${LINE#*">  "}
        FILE=${LINE%" ["*"]"*}
        LINE=${LINE##*" ["}
        SIZE=${LINE%"]"*}

       eval "echo \"$OUTPUT\""
      ;;
    esac
  done)
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

  eval "$CMD"
done
escape_dquote () 
{ 
    local s="$1";
    s=${s//"\\"/"\\\\"};
    s=${s//'$'/"\\"'$'};
    s=${s//'"'/'\"'};
    echo "$s"
}
