#!/bin/bash
#
# Given a J2ME midlet jarball, create a JAD for it
# Usage: ./jadmaker.sh <filename>

# safety check 1
FILE=$1
if [ ! -f "${FILE}" ]; then
  echo "Input file '${FILE}' missing, exiting."
  exit 1
fi

# safety check 2
JAD="${FILE%.*}.jad"
if [ -f "${JAD}" ]; then
  echo "${JAD} already exists, overwrite? (y/N)"
  read tmpans
  answer=$(echo "$tmpans" | tr '[:upper:]' '[:lower:]')
  if [ "$answer" != "y" ] && [ "$answer" != "yes" ]; then
    echo "Not overwriting ${JAD}, exiting."
    exit 1
  else
    rm -f "${JAD}"
  fi
fi

# unzip the internal manifest, changing line endings to our local OS
# the ${SED-sed} action removes blank lines, with or without spaces/tabs
unzip -aa -j -p ${FILE} "META-INF/MANIFEST.MF" | ${SED-sed} -e '/^[ \t]*$/d' > "${JAD}"

# generic variables
echo "MIDlet-Jar-URL: ${FILE}" >> "${JAD}"
echo "MIDlet-Info-URL: http://" >> "${JAD}"

# actual jarball size
FILESIZE=$(stat -c%s "${FILE}")
echo "MIDlet-Jar-Size: ${FILESIZE}" >> "${JAD}"

# weee
echo "Created ${JAD}."
exit 0

