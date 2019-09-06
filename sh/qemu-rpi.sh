#!/bin/sh
set -x
IMG="$1"
shift
exec qemu-system-arm \
   -kernel "$HOME/Sources/qemu-rpi-kernel/kernel-qemu-4.14.79-stretch" \
   -dtb "$HOME/Sources/qemu-rpi-kernel/versatile-pb.dtb" \
   -m 256 -M versatilepb -cpu arm1176 \
   -serial stdio \
   -append "rw console=ttyAMA0 root=/dev/sda2 rootfstype=ext4  loglevel=8 rootwait fsck.repair=yes memtest=1" \
   -drive file="$IMG",format=raw \
   -redir tcp:5022::22  \
   -no-reboot \
"$@"
