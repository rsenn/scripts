#!/bin/sh

IFS="
"

. require.sh

require xml
require distrib

eval "$(distrib_release)"

for METHOD in curl wget lynx w3m links; do
	if type "$METHOD" 2>/dev/null 1>/dev/null; then
		break
  fi
done

SED="sed"

if sed --help 2>&1 | grep -q '\-u'; then
  SED="$SED
-u"
fi

sed() {
	(set -- $SED "$@"
	set -x
	 "$@")
}

http_get() {
 (case "$METHOD" in
		curl)	CMD='curl -s -L -k $NO_CURLRC $VERBOSE_ARGS ${USER_AGENT+--user-agent
	"$USER_AGENT"} ${PROXY+--proxy
	"$PROXY"} --location -o - $ARGS "$@"' ;;
		wget) CMD=${PROXY+'http_proxy="$PROXY" '}'wget -q ${USER_AGENT+-U
	"$USER_AGENT"} --content-disposition -O - $ARGS "$@"' ;;
		lynx) CMD=${PROXY+'http_proxy="$PROXY" '}'lynx -source  ${USER_AGENT+-useragent="$USER_AGENT"}   $ARGS "$@" 2>/dev/null' ;;
		w3m) CMD=${PROXY+'http_proxy="$PROXY" '}${USER_AGENT+'user_agent="$USER_AGENT" '}'w3m -dump_source $ARGS "$@" 2>/dev/null | zcat -f' ;;
		links) CMD='links  -source  ${PROXY+-${PROXY%%://*}-proxy
	"${PROXY#*://}"} ${USER_AGENT+-http.fake-user-agent
	"$USER_AGENT"}   $ARGS "$@" |zcat -f' ;;
	esac
	eval "set -x; $CMD")
}

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
 (CMD='$SED -n "s|\\r*\$|| ;; s|^\([^/]\+\)/\([^/]\+\)\$|http://ppa.launchpad.net/\1/\2/ubuntu|p"'
	[ $# -gt 0 ] && CMD="$CMD <<<\"\$*\""
	eval "$CMD")
}

ppa-to-repodist() {
(IFS="/"; CMD='$SED -n "s|\\r*\$|| ;; s|.*/\([^/]\+\)/\([^/]\+\)/ubuntu.*|\1/\2| ;; s|^\([^/]\+\)/\([^/]\+\)\$|http://www.ubuntuupdates.org/\1/\2/ubuntu/dists/${codename}${*:+/$*}|p"'
	eval "$CMD")
}

if [ $# -gt 0 ]; then
	EXPR="($(IFS="|"; echo "$*"))"
fi

log "SED=\"$SED\""
URLS=$(http_get "http://www.ubuntuupdates.org/ppas" | grep -E "/ppa/.*(dist=|>)${EXPR:-(${release}|${codename})}(['\"]|<)" |
xml_get a href | addprefix "http://www.ubuntuupdates.org")

log "Got $(count $URLS) PPAs for ${release}${codename:+ ($codename)}"

#EXT_URLS=$(http_get $URLS | $SED -n '/>External PPA Homepage</p' | xml_get a href)
#log "Got $(count $EXT_URLS) URLs for ${release}${codename:+ ($codename)}"
#(set -x; http_get $EXT_URLS)|$SED -n "/^deb/ { 
#/<span/ {
#  :lp
#	  \,</span,! { N; s|\s\+| |g; b lp; }
#	}
#	s|<[^>]*>||g; ${release:+s|YOUR_UBUNTU_VERSION_HERE|$release|g}; P
#}"
#

http_get $URLS |$SED -n "s|^\\s*|| ;; s|\\s*\$|| ;; /add-apt-repository/ s|.*ppa:||p" |
ppa-to-repobase | 
ppa-to-repodist "Release"
