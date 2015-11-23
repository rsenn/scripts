#!/bin/bash

NL="
"
IFS="$NL"

cut_ver() 
{ 
    cat "$@" | sed 's,-[0-9][^-.]*\(\.[0-9][^-.]*\)*$,,'
}
BINS="$*"
BIN_1ST="$1"

BINS_NO_VER=$(cut_ver <<<"$BINS")
BINS_NO_VER_1ST=$(set -- $BINS_NO_VER; echo "$1")

VER=${BIN_1ST#$BINS_NO_VER_1ST}
VER=${VER#-}

echo "VER=$VER"

OUT=""

output() {
	OUT="${OUT:+$OUT }$@"
}

output update-alternatives --install /usr/bin/"${BINS_NO_VER_1ST##*/}" "${BINS_NO_VER_1ST##*/}" "${BIN_1ST}" "${PRIO:-30}"

set -- $BINS
shift

for BIN; do

	[ "$BIN" = "$BIN_1ST" ] && continue
	BIN_NOVER=$(cut_ver <<<"$BIN")
	output --slave /usr/bin/"${BIN_NOVER##*/}" "${BIN_NOVER##*/}" "${BIN}"

done

OUT=${OUT//" --"/$' \\\n\t--'}

echo "$OUT"
