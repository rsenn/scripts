#!/bin/sh

IFS="
"

. require.sh

require xml
require distrib

eval "$(distrib_release)"

addprefix() {
 (P=$1; shift
  C='echo "$P$L"'
  [ $# -gt 0 ] && C="for L; do $C; done" || C="while read -r L; do $C; done"
  eval "$C")
}

count() {
	echo $#
}

log() {
	echo "$@" 1>&2
}

ppa-to-repobase() {
 (CMD='sed -n "s|\\r*\$|| ;; s|^\([^/]\+\)/\([^/]\+\)\$|http://ppa.launchpad.net/\1/\2/ubuntu|p"'
	[ $# -gt 0 ] && CMD="$CMD <<<\"\$*\""
	eval "$CMD")
}

ppa-to-repodist() {
(CMD='sed -n "s|\\r*\$|| ;; s|.*/\([^/]\+\)/\([^/]\+\)/ubuntu.*|\1/\2| ;; s|^\([^/]\+\)/\([^/]\+\)\$|http://ppa.launchpad.net/\1/\2/ubuntu/dist/${codename}|p"'
	[ $# -gt 0 ] && CMD="$CMD <<<\"\$*\""
	eval "$CMD")
}

if [ $# -gt 0 ]; then
	EXPR="($(IFS="|"; echo "$*"))"
fi

URLS=$(curl -s "http://www.ubuntuupdates.org/ppas" | grep -E "/ppa/.*(dist=|>)${EXPR:-(${release}|${codename})}(['\"]|<)" |
xml_get a href | addprefix "http://www.ubuntuupdates.org")

log "Got $(count $URLS) PPAs for ${release}${codename:+ ($codename)}"

curl -s $URLS |sed -n "s|^\\s*|| ;; s|\\s*\$|| ;; /add-apt-repository/ s|.*ppa:||p" |
ppa-to-repobase | 
ppa-to-repodist
