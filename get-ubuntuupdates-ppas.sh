#!/bin/sh

IFS="
"

. require.sh

require xml
require distrib

SED=sed
GREP=grep

if sed --help 2>&1 | grep -q '\-u'; then
  SEDOPTS="-u"
else
	SEDOPTS=
fi

sed() {
	( #set -- "${@//$IFS/ ;; }"
	set -x
	 command $SED $SEDOPTS "$@")
}

grep() {
	(set -- $GREP $GREPOPTS "$@"
	set -x
	 command "$@")
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
  eval "$C") }

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
(IFS="/"; CMD='sed -n "s|\\r*\$|| ;; s|.*/\([^/]\+\)/\([^/]\+\)/ubuntu.*|\1/\2| ;; s|^\([^/]\+\)/\([^/]\+\)\$|http://www.ubuntuupdates.org/\1/\2/ubuntu/dists/${codename%/}${*:+/$*}|p"'
	eval "$CMD")
}

release-to-codename() {
  case "$1" in
    4.10) echo warty ;;
    5.04) echo hoary ;;
    5.10) echo breezy ;;
    6.06.2) echo dapper ;;
    6.10) echo edgy ;;
    7.04) echo feisty ;;
    7.10) echo gutsy ;;
    8.04.4) echo hardy ;;
    8.10) echo intrepid ;;
    9.04) echo jaunty ;;
    9.10) echo karmic ;;
    10.04.4) echo lucid ;;
    10.10) echo maverick ;;
    11.04) echo natty ;;
    11.10) echo oneiric ;;
    12.10) echo quantal ;;
    13.04) echo raring ;;
    13.10) echo saucy ;;
		14.04 | 14.04.1 | 14.04.2) echo trusty ;;
		14.10) echo utopic ;;
		15.04) echo vivid ;;
	esac
}

codename-to-release() {
  case "$1" in
    warty) echo 4.10 ;;
    hoary) echo 5.04 ;;
    breezy) echo 5.10 ;;
    dapper) echo 6.06.2 ;;
    edgy) echo 6.10 ;;
    feisty) echo 7.04 ;;
    gutsy) echo 7.10 ;;
    hardy) echo 8.04.4 ;;
    intrepid) echo 8.10 ;;
    jaunty) echo 9.04 ;;
    karmic) echo 9.10 ;;
    lucid) echo 10.04.4 ;;
    maverick) echo 10.10 ;;
    natty) echo 11.04 ;;
    oneiric) echo 11.10 ;;
    quantal) echo 12.10 ;;
    raring) echo 13.04 ;;
    saucy) echo 13.10 ;;
		trusty) echo 14.04 ;;
		utopic) echo 14.10 ;;
		vivid) echo 15.04 ;;
	esac
}

if [ $# -gt 0 ]; then
	if [ -n "$1" ]; then
		if [ -n "$(release-to-codename "$1")" ]; then
		  release="$1"
		elif [ -n "$(codename-to-release "$1")" ]; then
			release="$(codename-to-release "$1")"
		fi
	fi

	if [ -n "$2" ]; then
		if [ -n "$(codename-to-release "$2")" ]; then
		  codename="$2"
		elif [ -n "$(release-to-codename "$2")" ]; then
			codename="$(release-to-codename "$2")"
		fi
	fi
else
	eval "$(distrib_release)"

	if [ "$codename" = "n/a" ]; then
		unset codename
		unset release
	fi
fi

if [ -n "$codename" -a -z "$release" ]; then
	release=$(codename-to-release "$codename")
elif [ -n "$release" -a -z "$codename" ]; then
	codename=$(release-to-codename "$release")
fi

if [ -z "$codename" -o -z "$release" ]; then
	log "Need \${codename} and \${release}, please specify on command line"
fi

for METHOD in curl wget lynx w3m links; do
	if type "$METHOD" 2>/dev/null 1>/dev/null; then
		break
  fi
done

if [ $# -gt 0 ]; then
	EXPR="($(IFS="|"; echo "$*"))"
fi

URLS=$(http_get "http://www.ubuntuupdates.org/ppas" | grep -E "/ppa/.*(dist=|>)${EXPR:-(${release}|${codename})}(['\"]|<)" |
xml_get a href | addprefix "http://www.ubuntuupdates.org")

log "Got $(count $URLS) PPAs for ${release}${codename:+ ($codename)}"

#EXT_URLS=$(http_get $URLS | sed -n '/>External PPA Homepage</p' | xml_get a href)
#log "Got $(count $EXT_URLS) URLs for ${release}${codename:+ ($codename)}"
#(set -x; http_get $EXT_URLS)|sed -n "/^deb/ { 
#/<span/ {
#  :lp
#	  \,</span,! { N; s|\s\+| |g; b lp; }
#	}
#	s|<[^>]*>||g; ${release:+s|YOUR_UBUNTU_VERSION_HERE|$release|g}; P
#}"
#

http_get $URLS |sed -n "s|^\\s*|| ;; s|\\s*\$|| ;; /add-apt-repository/ s|.*ppa:||p" |
ppa-to-repobase | 
ppa-to-repodist "Release"
