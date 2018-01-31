#!/bin/sh

: ${EMAIL="enkilo@gmx.ch"}
: ${PASSWORD="lala"}
: ${PLAYER="mplayer"}

exec streamlink  \
  --zattoo-email "$EMAIL" \
  --zattoo-password "$PASSWORD" \
  -p "$PLAYER" \
  https://zattoo.com/watch/"${1##*/}" ${2-1500k}
