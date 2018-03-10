#!/bin/sh
#
# Watch zattoo.com using mplayer or similar
#
# Usage: env EMAIL=enkilo@gmx.ch PASSSWORD=lala PLAYER=mplayer zattoo.sh n24_doku 



: ${EMAIL="enkilo@gmx.ch"}
: ${PASSWORD="lalala"}
: ${PLAYER="mplayer"}

exec streamlink  \
  --zattoo-email "$EMAIL" \
  --zattoo-password "$PASSWORD" \
  -p "$PLAYER" \
  https://zattoo.com/watch/"${1##*/}" ${2-1500k}
