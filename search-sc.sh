#!/bin/bash

IFS="
"
URL="$1"

EVAL=$(echo "$URL" | sed 's/page=\([0-9]\+\)/page={`seq -s, 1 \1`}/ ; s/\&/\\&/g')

eval "set -- $EVAL"
echo "$*"
