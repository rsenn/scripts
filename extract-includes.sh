#!/bin/sh

exec sed -n 's/^\s*#\s*include\s\+[<"]\([^>"]\+\)[">].*/\1/p' "$@"
