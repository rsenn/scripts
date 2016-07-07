#!/bin/sh

mencoder "$1" -oac mp3lame -lameopts abr:br=128 -ovc xvid -xvidencopts bitrate=1000:pass=1 -vf pp=de,scale=480:-2 -o "${2-/dev/null}"

mencoder "$1" -oac mp3lame -lameopts abr:br=128 -ovc xvid -xvidencopts bitrate=1000:pass=2 -vf pp=de,scale=480:-2 -o "${2-${1%.mkv}}".avi
