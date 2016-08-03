#!/bin/sh



# search_path <name> <dir> <prefixes>
search_path()
{
 (NAME="$1" DIR="$2"
  shift 2
  IFS=":"
  if [ "$#" = 0 ]; then
    set -- ${*:-$PATH}
  fi
  for PREFIX in ${@%/bin}; do
    if [ -e "$PREFIX/$DIR/$NAME" ]; then
      echo "$PREFIX/$DIR/$NAME"
      exit 0
    fi
  done
  exit 1)
}  

PREFIXES="/opt/java:/usr/local:/usr"

if JAVA=`search_path java bin $PREFIXES` && [ "$JAVA" ] &&
   JMAC=`search_path jmac.jar share/java $PREFIXES` && [ "$JMAC" ]; then
  EXEC="$JAVA -jar $JMAC d \"\$INPUT\" \"\$OUTPUT\""
elif type ${FFMPEG-ffmpeg} >/dev/null; then
  EXEC="${FFMPEG-ffmpeg} -i \"\$INPUT\" \"\$OUTPUT\""
elif type mplayer >/dev/null; then
  EXEC="mplayer -ao pcm:file=${#OUTPUT}%\"\$OUTPUT\" \"$INPUT\""
fi

if [ "$EXEC" ]; then
  for INPUT; do
    OUTPUT="${INPUT%.[Aa][Pp][Ee]}.wav"
    eval "$EXEC" || exit $?
  done
else
  echo "No jmac, ${FFMPEG-ffmpeg} or mplayer found." 1>&2
  exit 2
fi
  
