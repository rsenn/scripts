#!/bin/sh
NL="
"

MIRRORS="ftp://mirror.switch.ch/mirror/cygwin/
ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/sourceware.org/cygwinports/"

CMD="-i"

while :; do
  case "$1" in
    -r | -e) CMD="$1"; shift ;;
    *) break ;;
  esac
done

get_mirror()
{
  ${SED-sed} -n 's,mirror_url=,,p' /etc/setup/cygsetup.conf 
}

IFS="
"
MIRROR=`get_mirror`
ARGS=

for A; do
  ARGS="${ARGS:+$ARGS|}$A"
done

for M in $MIRRORS; do
  echo "Current mirror: $MIRROR"
  echo "New mirror: $M"  

  if [ "$MIRROR" != "$M" ]; then
    (set -x; cygsetup --mirror="$M" >/dev/null) || continue
    MIRROR="$M"
  fi

  set -- $(
		cygsetup -l -a | ${GREP-grep -a --line-buffered --color=auto} -i -E "($ARGS)" 
  )

  if [ $# -ge 1 ]; then
    echo "$*"
    echo
    (set -x; cygsetup -i "${@%% *}") ||
    break
  fi

done
