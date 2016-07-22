#!/bin/sh
# Tunnel a x2x connection to a second machine, presumed to be at
# the right of this machine's screen.

host="$1"
mount_dir="$HOME/$host"
direction="east"  # west means the OTHER screen is to the left

echo "Creating $mount_dir"
mkdir -p $mount_dir
echo "Mounting remote machine at $mount_dir"
sshfs cactus: $mount_dir

echo "Connecting to remote machine for x2x over ssh"
ssh -X $host "x2x -$direction -to :0"

# after ctrl-C killing above session, clean up sshfs stuff
# sshfs automatically unmounts when you ctrl-C out of above command
echo "Removing mount point"
rmdir $mount_dir


