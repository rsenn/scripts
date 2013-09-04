#!/bin/sh
for URL; do
  lynx -dump -listonly -nonumbers -hiddenlinks=merge "$URL"
done
