#!/bin/bash
FONTFORGE="C:/Program Files (x86)/FontForge/bin/fontforge.exe"

DISPLAY=":0"

export DISPLAY

ME=`basename "$0" .sh`
TEMP=`mktemp "${ME}XXXXXX"`

trap 'rm -f "$TEMP"' EXIT

SCRIPT='#!/usr/bin/fontforge
# Quick and dirty hack: converts a font to truetype (.ttf)
Open($1);
Generate($1:r+".ttf");
Quit(0);
'

echo "$SCRIPT" >"$TEMP"

"$FONTFORGE" "$TEMP" "$@" 

