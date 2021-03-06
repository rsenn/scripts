#!/bin/sh
set -x
IMG="$1"
shift
exec qemu-system-aarch64 \
  -kernel debian_bootpart/vmlinuz-4.14.0-3-arm64 \
  -initrd debian_bootpart/initrd.img-4.14.0-3-arm64 \
  -m 1024 -M virt \
  -cpu cortex-a53 \
  -serial stdio \
  -append "rw root=/dev/vda2 console=ttyAMA0 loglevel=8 rootwait fsck.repair=yes memtest=1" \
  -drive file="$IMG",format=raw,if=sd,id=hd-root \
  -device virtio-blk-device,drive=hd-root \
  -netdev user,id=net0,hostfwd=tcp::5022-:22 \
  -device virtio-net-device,netdev=net0 \
  -no-reboot \
  "$@"
