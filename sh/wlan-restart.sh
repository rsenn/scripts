#!/bin/sh
#
# -*-mode: shell-script-*-
#
# wlan-restart.sh
#
# Copyright (C) 2008  Roman Senn <roman@digitall.ch>
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


# Usage
# --------------------------------------------------------------------------- 
usage()
{
  msg "usage: ${0##*/} [-b BRIDGE_IF-interface] [-h host-interface]"
  exit 0
}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  BRIDGE_IF=`${SED-sed} -n 's,^\s*\(br[0-9]\+\):.*,\1,p' /proc/net/dev`
  WLAN_IF=wlan0
  NET_IF=${BRIDGE_IF:-$WLAN_IF}

  ESSID=`iwconfig "$WLAN_IF" | ${SED-sed} -n "s/.*ESSID:\"\([^\"]*\).*/\1/p"`
  DRIVER=iwlagn
  DHCPID=`pgrep -f "dhc[^ ]* ${NET_IF}"`

  kill "$DHCPID"
  ifconfig "$WLAN_IF" down
  rmmod "$DRIVER"
  modprobe "$DRIVER"

  if [ "$BRIDGE_IF" ]; then
    ifconfig "$WLAN_IF" 0 up
    brctl addif "$BRIDGE_IF" "$WLAN_IF"
  fi

  iwconfig "$WLAN_IF" essid "$ESSID"
  dhclient "$NET_IF"
}

# ===========================================================================
main "$@"

#EOF
