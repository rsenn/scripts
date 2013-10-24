#!/bin/bash


while read -r LINE; do

  case "$LINE" in
     *"(FOLDER)"*) FOLDER=${LINE#*"(FOLDER) "} ;;
     *"(FILE)"*)
       FILE=${LINE#*"(FILE) "} 
       FILE=${FILE%" = "??.??.????" "??:??", "*" bytes, "*}
       
       echo "$FOLDER\\$FILE"
       
       ;;
    esac
    done
       
        