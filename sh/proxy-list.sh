#!/bin/sh
NL="
"

# provide default values for the required path variables.
# ---------------------------------------------------------------------------
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# ---------------------------------------------------------------------------
. $shlibdir/util.sh
. $shlibdir/data/xml.sh
. $shlibdir/net/www/curl.sh

# static variables
# ---------------------------------------------------------------------------
PROXY_timeout_msecs=500

# proxy_list
# ---------------------------------------------------------------------------
proxy_list()
{
  curl_get "$PROXY_url/" |
  xml_get a href | 
  ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "$PROXY_mask" | {
    LISTS=
    while read LIST; do
      if ! isin $LIST $LISTS; then
        curl_get "$PROXY_url/$LIST" | 
        ${SED-sed} -n "s/.*[^0-9]\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:[0-9]\+\).*/\1/p"
        pushv LISTS $LIST
      fi
    done
  } |
  uniq
}

# ---------------------------------------------------------------------------
main()
{
  # parse command line options using shflags
  . shflags

  DEFINE_boolean help "$FLAGS_FALSE"            "show this help" h
  DEFINE_boolean debug "$FLAGS_FALSE"           "enable debug mode" D
  DEFINE_boolean verbose "$FLAGS_FALSE"         "verbose output" v
  DEFINE_boolean check "$FLAGS_FALSE"           "check using tcping" c

  FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
  FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

#  msg "Executing main $@"

  proxy_list |
  while read PROXY; do
    ADDR=${PROXY%%:*}
    PORT=${PROXY#*:}

    if [ "$FLAGS_check" = "$FLAGS_TRUE" ]; then
     tcping -u"`expr $PROXY_timeout_msec \* 1000`" "$ADDR" "$PORT" 

     [ "$?" = 0 ] || unset PROXY
    fi

    if [ "$PROXY" ]; then
      echo "$PROXY"
    fi
  done

}

# ---------------------------------------------------------------------------
case "${0##*/}" in
  proxy-list | proxy-list.*) main "$@" ;;
esac

# ---[ EOF ]-----------------------------------------------------------------
