#!/bin/bash

skip=$(( ${2:-0} ))
(set -x; dd bs=1 skip="$skip" if="$1" ) | hexdump -v -C |${SED-sed} -n '/  48 2b 00 04.*|H+/ { s,^0*,, ; s,^,0x, ; s, .*,, ; p; q; }'
