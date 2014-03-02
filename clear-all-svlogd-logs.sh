#!/bin/sh -e
LOGDIR=/var/log ; killall -HUP svlogd ; killall -USR1 svlogd ; find "$LOGDIR" -name "@*" -exec rm -v "{}" ";"
