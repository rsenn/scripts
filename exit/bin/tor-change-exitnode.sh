#!/bin/sh
###
#
# Change Tor exit node
#
# Sometimes when using Tor you'd like to change the IP address that
# servers see when you connect (that is, change your Tor exit node).
# This happens automatically from time to time, but this shell script
# lets you force it.
#
# Add these lines to `/etc/tor/torrc` to enable Tor's control interface:
# ControlPort 9051
# HashedControlPassword <hash of password>
# (Use `tor --hash-password <password>` to get a hash of your password.)
# If you want to control a remote Tor (say, running on another host in your LAN)
# it is recommended not to use `ControlListenAddress`. The proper way is to
# make that Tor-daemon bind to localhost (default) and create a tunnel.
# The script uses SSH for this.
#
#
# https://gist.github.com/9667900
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it
# under the terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
#
# -- Kirill Elagin <kirelagin@gmail.com>
# http://kir.elagin.me/
###
 
 
: ${TORHOST=127.0.0.1}
: ${TORPORT=9050}
: ${CTRLPORT=9051} # Matters only if TORHOST is not `localhost`
: ${CTRLPASS=""} # Better leave it empty
 
if [ "${CTRLPASS-unset}" = unset ]; then
  echo -n "Tor control password: "
  read -s CTRLPASS
  echo
fi
 
if [ "$TORHOST" != "127.0.0.1" ]; then
  ssh -f -o ExitOnForwardFailure=yes -L "$CTRLPORT:127.0.0.1:$TORPORT" "$TORHOST" sleep 1
  TORPORT="$CTRLPORT"
fi
 
(
set -x
${NETCAT-nc} "$TORHOST" "$CTRLPORT" <<EOF
authenticate "${CTRLPASS}"
signal newnym
quit
EOF
) || echo "Connection failed." >&2