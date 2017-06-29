#!/bin/sh
MYNAME=$(basename "$0" .sh)
MYDIR=$(dirname "$0")

set_var() {
    eval "shift;$1=\"\$*\""
}
str_toupper ()
{
    echo "$@" | tr "[[:lower:]]" "[[:upper:]]"
}


find_program() {
  V=$1
  N=$2
  S=$3
  if [ -e scripts/"$N" ]; then
    P=scripts/"$N"
  elif type "$N" 2>/dev/null >/dev/null; then
    P=$N
  else
    P=$(ls -d {scripts/,/usr/,$SYSTEMDRIVE/{Programs,Program\ Files*}/*/,/mingw{32,64}/,$SYSTEMDRIVE/"$(str_toupper "$N")"*/}{,bin/}"$N".exe 2>/dev/null)
    [ -n "$P" -a -e "$P" ] || {
      if [ -n "$S" ]; then 
        P=$(eval "$S")
        type  cygpath 2>/dev/null >/dev/null && P=$(cygpath "$P")
        [ -z "$P" -o '!' -e "$P" ] && unset P
      else 
    unset P
      fi      
    }
  fi
  if [ -n "$P" ]; then
    msg "Found $V: $P"
  set_var "$V" "$P"
  else
    return 1
  fi
}

get_pdf_info() {
 (TMP=$(mktemp  pdftkXXXXXX.txt)
  trap '${RMTEMP} -f "$TMP"' EXIT
  "$PDFTK" "$1" dump_data output "$TMP"
  cat "$TMP")
}

msg() {
  echo "${MYNAME:+$MYNAME: }$@" 1>&2
}

error() {
R=$?
echo "ERROR: $@" 1>&2
exit $R
}

exec_cmd() {
 (VAR="$1"
  shift
  IFS="
"
  eval "echo \"Executing: \${$VAR}\" \"\$@\"; echo"

 (echo -n "$VAR "
  for X in  "$@"; do echo -n "'$X' "; done) 1>&2
  eval "env - PATH=\"\$PATH\" \"\${$VAR}\" \"\$@\" 2>&1"
  R=$?
  echo " (R=$R)" 1>&2)  1>&10
}

svg_set_size() {
  sed -i "/<svg / { s|width=\"[^\"]*\"|width=\"$2\"| ; s|height=\"[^\"]*\"|height=\"$3\"| }" "$1"
}

inkscape_crop_svg() {
  while [ -n "$1" -a -f "$1" ]; do 
  rm -f "${1%.svg}.tmp.svg"
    exec_cmd INKSCAPE --export-plain-svg="${1%.svg}.tmp.svg" "$1"
    mv -vf "${1%.svg}.tmp.svg" "$1"
    exec_cmd INKSCAPE --verb=FitCanvasToDrawing --verb=FileSave --verb=FileClose --verb=FileQuit "$1" &
    shift
  done

}



eagle_to_svg() {

  INPUT=$1
  OUTPUT=${2:-${1%.*}.pdf}
  rm -f -- "$OUTPUT"
  OPTIONS=$3
  : ${SCALE:=1.0}
  : ${PAPER:="a4"}
  ORIENTATION=${4:-${ORIENTATION:-portrait}}
  EAGLE_CMD="PRINT $ORIENTATION $SCALE -0 -caption ${OPTIONS:+$OPTIONS }FILE '${OUTPUT}' sheets all paper $PAPER"

 echo "Processing $1 ..." 1>&2
 echo 1>&2

  case $INPUT in
     *.brd)   EAGLE_CMD="DISPLAY -bKeepout -tKeepout -bRestrict -tRestrict -bTest -tTest -bOrigins -tOrigins -bStop -tStop -bCream -tCream -Drills -Holes -Document -Reference bValues tValues; $EAGLE_CMD" ;;
   esac
  EAGLE_CMDS=${EAGLE_CMDS:+"$EAGLE_CMDS; "}$EAGLE_CMD

 exec_cmd EAGLE -N- -C "$EAGLE_CMD; QUIT"      "$INPUT" &
  pid=$!

  while [ ! -s "$OUTPUT" ]; do
    sleep 0.1
  done

  sleep 0.1

  kill $pid 2>/dev/null
  wait $pid

 : || (TMP=$(mktemp infoXXXXXX.txt)
  trap 'mv -f -- "$OUTPUT.$$" "$OUTPUT"; rm -f "$TMP"' EXIT
  cat >$TMP <<EOF
InfoBegin
InfoKey: Title
InfoValue: $(basename "$OUTPUT" .pdf)
EOF
   exec_cmd PDFTK "$OUTPUT" update_info "$TMP" output  "$OUTPUT.$$")
  echo 1>&2
}

eagle_print() {

  : ${RMTEMP:=rm}

  export HOME="$(cygpath -a "$USERPROFILE")"

  exec 10>$MYNAME.log

  find_program EAGLE "eagle" 'reg query "HKLM\SOFTWARE\Classes\Applications\eagle.exe\shell\open\command" |sed "s,.*REG_SZ\s*\"\?\(.*\.exe\).*,\1,p" -n' || error "eagle not found"
  find_program INKSCAPE "inkscape" 'reg query "HKLM\SOFTWARE\Classes\inkscape.svg\shell\edit\command" |sed "s,.*REG_SZ\s*\"\?\(.*\.exe\).*,\1,p" -n' || error "Inkscape not found"
  find_program PDFTK "pdftk" || error "pdftk not found"
  find_program PDFTOCAIRO "pdftocairo" || error "pdftocairo not found"

EAGLE=${EAGLE//eagle.exe/eaglecon.exe}

I=0
N=$#
   
  for ARG; do
   I=$((I+1))
   echo "Processing '$ARG' ($((I))/$((N)))" 1>&2
   (SCH=${ARG%.*}.sch
    if [ ! -e "${SCH}.sch" ]; then
      SCH=${SCH%-[[:lower:]]*}.sch
    fi
    BRD=${ARG%.*}.brd
    BASE=$(basename "${BRD%.*}")
    OUT=doc/pdf/$(basename "${BRD%.*}").pdf
    trap '${RMTEMP} -f "${BRD%.*}"-{schematic,board,board-mirrored}.{pdf,svg}' EXIT

#  ORIENTATION="portrait" PAPER="a4" SCALE=1.0 eagle_to_svg "$SCH" "${SCH%.*}-schematic.pdf"
  ORIENTATION="landscape" PAPER="a4" SCALE="0.8 -1" eagle_to_svg "$SCH" "${SCH%.*}-schematic.pdf"

  #ORIENTATION="landscape" PAPER="a5"  SCALE="3.0 -1"
   ORIENTATION="landscape" PAPER="a5"  SCALE="1.0"
#   ORIENTATION="landscape" PAPER="a4"  SCALE="2.0"

     # set -e

    eagle_to_svg "$BRD" "${BRD%.*}-board.pdf"
    eagle_to_svg "$BRD" "${BRD%.*}-board-mirrored.pdf" MIRROR

    echo "Blah" 1>&2
    

   (for OUTPUT in "${SCH%.*}"-schematic.pdf \
  "${BRD%.*}"-{board,board-mirrored}.pdf \
  ; do
      echo "Converting $OUTPUT ..." 1>&2
      echo 1>&2
      exec_cmd PDFTOCAIRO -svg "$OUTPUT" "${OUTPUT%.pdf}.svg" && ${RMTEMP} -vf -- "$OUTPUT"
      inkscape_crop_svg "${OUTPUT%.pdf}.svg"
    done)
    
    
   (set -x;
   rm -f "${BASE}-boards.svg"
   "$MYDIR"/svg_stack.py  --direction=h --margin=1 \
      "${BRD%.*}"-{board,board-mirrored}.svg \
     >"${BASE}-boards.svg"
   
   rm -f "${BASE}.svg"
   "$MYDIR"/svg_stack.py  --direction=v --margin=5 \
      "${SCH%.*}-schematic.svg" \
      "${BASE}-boards.svg" \
     >"${BASE}.svg"
    )
    
    svg_set_size "${BASE}.svg" 595.27559 841.88976
  # exec_cmd INKSCAPE --verb=EditSelectAll --verb=AlignHorizontalLeft --verb=AlignVerticalTop --verb=FileSave --verb=FileQuit "${BASE}.svg"
    exec_cmd INKSCAPE --export-area-drawing -f "$BASE.svg" -A "$BASE.pdf"
      
      
#  exec_cmd PDFTOCAIRO -svg  "$FILE" "${FILE%.*}.svg" || exit $?
#
#  done)
  ); done
}

eagle_print "$@"
