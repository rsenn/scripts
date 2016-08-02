#!/bin/sh

exec ${SED-sed} -n 's/^\s*#\s*include\s\+[<"]\([^>"]\+\)[">].*/\1/p' "$@"
