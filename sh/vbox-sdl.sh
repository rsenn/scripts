#!/bin/sh

NAME="XP"
DISK="/global/blackbox/xp1.vdi"
CDROM="/global/blackbox/software/isos/clonezilla-live-1.2.1-50.iso"
#MODE="1024x768x24"
MODE="1400x900x24"

sudo rmmod kvm_intel kvm

IFS="${IFS}x"

exec VBoxSDL \
  -vm "$NAME" \
  ${DISK:+"-hda" "$DISK"} \
  ${CDROM:+"-cdrom" "$CDROM"} \
  ${MODE:+"-fixedmode" $MODE}

