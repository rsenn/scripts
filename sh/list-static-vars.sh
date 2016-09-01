#!/bin/sh
exec ${SED-sed} \
  -n '/^[_0-9A-Za-z]\+=/ {
  
  /=:;/! s,=.*,,p
}' "$@"
