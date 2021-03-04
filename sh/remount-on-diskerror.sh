#!/bin/sh
NL="
"
MOUNTPOINT=/mnt/toshiba

get_mount() {
  IFS=" "
  while read -r DEV MNT TYPE OPTS DUMP PASS; do
    if [ "$DEV" = "$1" -o "$MNT" = "$1" ]; then
      #echo "$DEV" "$MNT" "$TYPE" "$OPTS" "$PASS"
      return 0
    fi
  done
  unset DEV MNT TYPE OPTS DUMP PASS
  return 1
} </proc/mounts

get_fuser_pids() {
  (
    OUTPUT=$(fuser -m -M "$1" 2>&1)
    OUTPUT=${OUTPUT#*:}
    set -- $OUTPUT
    echo "$OUTPUT" | sed "s|^\\s\\+||; s|\\s\\+|\\n|g ; s|[a-z]||g"
  )
}

kernel_errors() {
  ERRORS=$(dmesg | grep " error on dev ${1##*/} ")

  if [ -n "$ERRORS" ]; then
    dmesg -c
    return 0
  else
    unset ERRORS
    return 1
  fi
}

while :; do

  if get_mount "$MOUNTPOINT"; then
    DISK=$DEV
    if ! kernel_errors "$DEV"; then
      sleep 5
      continue
    else
      echo "Errors in kernel log for device '${DEV}'" 1>&2

      sleep 1
      (
        set -x
        umount "$MOUNTPOINT" || umount -l "$MOUNTPOINT"
      )
    fi
  else
    echo "Device '${DISK}' at mount '${MOUNTPOINT}' got unmounted..." 1>&2
  fi

  (
    set -x
    systemctl stop smbd
  )

  # PIDS=$(get_fuser_pids "$MOUNTPOINT")

  PIDS=$(
    set +x
    lsof -n 2>/dev/null | grep "$MOUNTPOINT" | awk '{ print $2 }' | sort -u
  )

  set -- $PIDS
  echo "Processes:" 1>&2
  if [ -n "$PIDS" ]; then
    (
      set -x
      ps -p "$PIDS"
      IFS="$IFS,"
      kill -9 $PIDS
    )
  fi

  (
    set -x
    mount "$MOUNTPOINT"
  )

  (
    set -x
    systemctl start smbd
  )
done
