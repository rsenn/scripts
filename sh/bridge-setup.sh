#!/bin/bash
#
# -*-mode: shell-script-*-
#
# BRIDGE_IF-setup.sh
#
# Copyright (C) 2008 Roman Senn,,,
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
# 
# $Id: GPL@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-08-05 Roman Senn,,, <enki@phalanx>
#

# set path variable defaults
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/std/var.sh
. $shlibdir/net/ethernet.sh
. $shlibdir/net/ip4.sh
. $shlibdir/net/if.sh
. $shlibdir/net/bridge.sh

# Usage
# --------------------------------------------------------------------------- 
usage()
{
  msg "usage: ${0##*/} [-b bridge-interface] [-h host-interface] [-n num-taps] [-u tap-user] [-g tap-group]

-b bridge-interface  Name of the bridge interface that will be created.
-h host-interface    Name of the host interface which should be replaced by the bridge.
-n num-taps          Number of virtual tap interfaces to create on the bridge.
-u tap-user          User which has access to the virtual tap interfaces.
-g tap-group         Group which has access to the virtual tap interfaces."
  exit 0
}

# Create taps
# ---------------------------------------------------------------------------
create_taps()
{
  N=${NUM_TAPS:-0}

  while [ "$N" -gt 0 ]; do
    TAP_IF=`tunctl -b ${TAP_USER:+-u "$TAP_USER"} ${TAP_GROUP:+-g "$TAP_GROUP"}`

    brctl addif "$BRIDGE_IF" "$TAP_IF"
    ifconfig "$TAP_IF" 0 up

    msg "Created and bound $TAP_IF to $BRIDGE_IF."

    N=`expr $N - 1`
  done

  if [ "$TAP_GROUP" ]; then
    chmod g+rw /dev/net/tun
    chgrp "$TAP_GROUP" /dev/net/tun
  fi
}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  BRIDGE_IF="br0" 
 # HOST_IF=${1:-eth0}
  CMD="up"

  while [ "$#" -gt 0 ]; do
    case $1 in
      -b) BRIDGE_IF=$2 && shift ;; -b*) BRIDGE_IF=${1#-b} ;;
      -h) HOST_IF=$2 && shift ;; -h*) HOST_IF=${1#-h} ;;
      -n) NUM_TAPS=$2 && shift ;; -n*) NUM_TAPS=${1#-n} ;;
      -u) TAP_USER=$2 && shift ;; -u*) TAP_USER=${1#-u} ;;
      -g) TAP_GROUP=$2 && shift ;; -g*) TAP_GROUP=${1#-g} ;;
      up|down) CMD="$1" ;;
      *) [ -z "$HOST_IF" ] && HOST_IF="$1" || usage ;;
    esac
    shift
  done

  if [ -z "$HOST_IF" ]; then
    error "No host interface specified"
  fi

  case $CMD in
    up)
      HOST_LIST=`if_list "$HOST_IF"`

      #for IF in $HOST_LIST; do
      #HOST_ADDR=`if_get_addr "$HOST_IF"`
      #HOST_BCAST=`if_get_addr "$HOST_IF" bcast`
      #HOST_MASK=`if_get_addr "$HOST_IF" mask`
      HOST_ROUTES=`if_get_routes "$HOST_IF"`

      brctl addbr "$BRIDGE_IF" || error "Bridge $BRIDGE_IF already exists."
      
      for IF in $HOST_LIST; do
        V=`str_replace "$IF" : _`

        ADDR=`if_get_addr "$IF"`
        BCAST=`if_get_addr "$IF" bcast`
        MASK=`if_get_addr "$IF" mask`

        if [ "$ADDR" ]; then
          var_set ${V}_ADDR `if_get_addr "$IF"`
          var_set ${V}_BCAST `if_get_addr "$IF" bcast`
          var_set ${V}_MASK `if_get_addr "$IF" mask`
        fi
      done

      ip addr flush dev "$HOST_IF"

      ip link set "$HOST_IF" down
      ip link set "$HOST_IF" promisc on #|| ifconfig "$HOST_IF" 0.0.0.0 promisc
      ip link set "$HOST_IF" up

      for IF in $HOST_LIST; do
        V=`str_replace "$IF" : _`

        ADDR=`var_get ${V}_ADDR`
        BCAST=`var_get ${V}_BCAST`
        MASK=`var_get ${V}_MASK`

        if [ "$ADDR" ]; then
          BRIDGE_ALIAS="$BRIDGE_IF${IF#$HOST_IF}"

          msg "Setting $BRIDGE_ALIAS to $ADDR netmask $MASK broadcast $BCAST"

          if_set_addr "$BRIDGE_IF${IF#$HOST_IF}" "$ADDR" "$MASK" "$BCAST"

          ip link set "$BRIDGE_IF${IF#$HOST_IF}" up
        fi
      done

      brctl addif "$BRIDGE_IF" "$HOST_IF"

      create_taps
    ;;

    down)
      ip addr flush dev "$BRIDGE_IF"
      ip link set "$BRIDGE_IF" down
       
      SLAVES=`bridge_slaves "$BRIDGE_IF"`

      for SLAVE in $SLAVES; do
        case $SLAVE in
          tap[0-9]*) 
            bridge_remove "$BRIDGE_IF" "$SLAVE"
            tunctl -d "$SLAVE"
          ;;
        esac
      done

      brctl delbr "$BRIDGE_IF"
    ;;
  esac
}

# ===========================================================================
main "$@"

#EOF
