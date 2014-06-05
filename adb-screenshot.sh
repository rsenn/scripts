#!/bin/sh

ADB=adb
DIR=/storage/emulated/legacy
NAME=${1-screen.png}
NAME=${NAME%.png}

set -x 
adb shell screencap -p "$DIR/${NAME##*/}.png"
adb pull "$DIR/${NAME##*/}.png" "$NAME.png"

