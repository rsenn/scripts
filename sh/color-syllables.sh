#!/bin/sh

while read COLOR; do
  hyphenate "$COLOR"
done <colors.list
