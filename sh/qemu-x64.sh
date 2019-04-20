#!/bin/bash

MAC=$(printf "%02x:%02x:%02x:%02x:%02x:%02x\n" $((RANDOM % 0xff)) $((RANDOM % 0xff)) $((RANDOM % 0xff)) $((RANDOM % 0xff)) $((RANDOM % 0xff)) $((RANDOM % 0xff)))

ETH=$(sed -n 's|^\s*||;  s|:.*||; /^e/ { p; q }' /proc/net/dev | sort -u | awk '{ print $1 }')


TAPDEVS=$(sed -n 's|^\s*||;  s|:.*||; /^tap/p' /proc/net/dev | sort -u | awk '{ print $1 }')

LASTTAP=$(set -- $TAPDEVS;  set -- "${@#tap}"; eval "echo \${$#}")
[ "$LASTTAP" -ge 0 ] 2>/dev/null &&
LASTTAP=$((LASTTAP + 1)) ||
LASTTAP=0

TAP=tap$LASTTAP
BR=br0


echo "MAC: $MAC" 1>&2
echo "ETH": $ETH 1>&2
echo "TAPDEVS": $TAPDEVS 1>&2
echo "LASTTAP": $LASTTAP 1>&2

sudo ip link del $BR 
sudo ip link del $TAP

sudo ip link add $BR type bridge
sudo ip addr flush dev $ETH
sudo ip link set $ETH master $BR
sudo ip tuntap add dev $TAP mode tap user $(whoami)
sudo ip link set $TAP master $BR
sudo ip link set dev $BR up
sudo ip link set dev $TAP up

#
#sudo brctl addbr  "$BR"
#sudo tunctl ${USER:+-u "$USER"} -t "${TAP}"
#sudo brctl addif "$BR" "$TAP"
#sudo ifconfig "$BR" 10.5.5.1 netmask 255.255.255.254 up
#sudo ifconfig "$TAP" 0 up

exec qemu-system-x86_64 \
  -m 1024 \
  -enable-kvm \
  -device rtl8139,netdev=network${TAP#tap},mac="$MAC" \
  -netdev tap,id=network${TAP#tap},ifname=$TAP,script=no,downscript=no \
  -net user,host=10.5.5.2,net=10.5.5.0/27,dhcpstart=10.5.5.20 \
  "$@"
