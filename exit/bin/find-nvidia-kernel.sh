#!/bin/sh

find /lib/modules/ -name nvidia.ko | 
while read path
do
  version=${path#/lib/modules/}
  version=${version%%/*}

  test -e /boot/vmlinuz-$version && echo $version  
done
