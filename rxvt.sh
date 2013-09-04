#!/bin/bash

FN="-misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15"
FB="$FN"

exec /usr/bin/rxvt +sb -rv -fn "$FN" -fb "$FB" -title Terminal -ls -bg gray
