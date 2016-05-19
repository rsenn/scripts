#!/bin/sh
#
# From: http://www.bonashen.com/post/artifice/running-mac-os-x-as-a-qemu-kvm-guest

BIOS_URL="https://cloud.github.com/downloads/fishman/qemu/bios-mac.bin"
BOOT_URL="https://github.com/ErisBlastar/qemuosxguest/raw/master/chameleon_2.0_boot"

[ -e "/usr/share/qemu/${BIOS_URL##*/}" ] || curl -k -L -o "/usr/share/qemu/${BIOS_URL##*/}" "$BIOS_URL"
[ -e "/usr/share/qemu/${BOOT_URL##*/}" ] || curl -k -L -o "/usr/share/qemu/${BOOT_URL##*/}" "$BOOT_URL"

MEMORY=2047
ACPITABLE=/usr/share/qemu/q35-acpi-dsdt.aml
#APPLESMC_OSK="insert-real-64-byte-OSK-string-here" 
#DRIVE_IMAGE="./mac_hdd.img"
NETDEV=eth1 
#MONITOR=stdio

set -x
exec qemu-system-x86_64 \
	-enable-kvm \
	${MEMORY:+-m "$MEMORY"}  \
	-cpu core2duo \
	-usb -device usb-kbd -device usb-mouse \
	-bios "/usr/share/qemu/${BIOS_URL##*/}" \
  -kernel "/usr/share/qemu/${BOOT_URL##*/}" \
	${APPLESMC_OSK:+-device isa-applesmc,osk="$APPLESMC_OSK"} \
	${ACPITABLE:+-acpitable file="$ACPITABLE"} \
	-device ahci,id=ide \
	${DRIVE_IMAGE:+-device ide-drive,bus=ide.2,drive=MacHDD \
                 -drive id=MacHDD,if=none,file="$DRIVE_IMAGE"} \
	-netdev user,id=hub0port0 -device e1000,netdev=hub0port0,id="$NETDEV" \
	${MONITOR:+-monitor "$MONITOR"} \
  "$@"
