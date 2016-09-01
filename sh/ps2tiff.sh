#!/bin/sh
for ARG; do
  OUT="${ARG%.ps}.tif"
gs -sDEVICE=tifflzw -dBATCH -dSAFER -dNOPAUSE -sOutputFile="$OUT" "$ARG" 
done
