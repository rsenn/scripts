#!/bin/bash
FONTFORGE="C:/Program Files (x86)/FontForge/bin/fontforge.exe"

DISPLAY=":0"

export DISPLAY

ME=`basename "$0" .sh`
TEMP=`mktemp "${ME}XXXXXX"`

trap 'rm -f "$TEMP"' EXIT

SCRIPT='#!/usr/bin/fontforge
# Quick and dirty hack: converts a font to opentype (.otf)
Open($1);
Generate($1:r+".otf");
Quit(0);
'

echo "$SCRIPT" >"$TEMP"

OUTPUT="${1%.[Tt][Tt][Ff]}.otf"
DEST="${2:-$OUTPUT}"

"$FONTFORGE" "$TEMP" "$1" 

if [ "$OUTPUT" != "$DEST" ]; then
mv -vf "$OUTPUT" "$DEST"
fi

