#!/bin/sh
exec sed \
  -n '/^[_0-9A-Za-z]\+=/ {
  
  /=:;/! s,=.*,,p
}' "$@"
