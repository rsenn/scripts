#!/bin/bash

mpc listall | 
clwrap -e ls -l "/var/lib/mpd/music/{}" ";" | 
sort -nk5 | 
sed 's,.*/var/lib/mpd/music/,,'
