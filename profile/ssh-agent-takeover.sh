# ssh-agent-takeover.sh
#
# This script is meant to be put in /etc/sysprofile.d
#
# It helps in a situation where you haven't started the ssh-agent as
# a parent process of the process launching your shells.
#
# -*-mode: shell-script-*-
#

# set path variable defaults
# ---------------------------------------------------------------------------
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# include library modules
# ---------------------------------------------------------------------------
. $shlibdir/util.sh
. $shlibdir/net/ssh.sh

# watch out for an ssh-agent and take it over
# ---------------------------------------------------------------------------
if [ -z  "$SSH_AUTH_SOCK" ]; then
  for SOCKET in /tmp/ssh-*/agent.*; do

    PROC=${SOCKET##*.}

    if [ -e "/proc/$PROC/stat" ]; then

       msg "Found ssh-agent [$PROC], taking it over."

       SSH_AUTH_SOCK="$SOCKET"
       SSH_AUTH_PROC="$PROC"

       unset SOCKET PROC
       break
    fi
  done
fi
