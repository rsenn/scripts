#!/bin/sh

IFS="
"
while :; do
  case "$1" in
    -s | --show-size | --*size*) SHOW_SIZE=true; shift ;;
    -n | --derive-name | --*name*) DERIVE_NAME=true; shift ;;
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

ARGS="$*"
OUTPUT='${DIR:+$DIR/}${FILE}'
CMD='ctor_listfiles'


[ "$SHOW_SIZE" = true ] && OUTPUT="$OUTPUT [\$SIZE]"

if [ "$DERIVE_NAME" = true ]; then
  CMD="$CMD | sed s,/.*,, | uniq"
fi
for ARG in $ARGS; do
  CTOR=$(ctorrent -x "$ARG")

  eval "$CMD"
done
