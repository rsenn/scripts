if type ssh-agent 2>/dev/null >/dev/null; then

	if [ -z "$SSH_AUTH_SOCK" -o ! -r "$SSH_AUTH_SOCK" ]; then
		unset SSH_AUTH_SOCK
	fi

	SSH_AGENT_PIDS=`pgrep -f ssh-agent`
	if [ -n "$SSH_AGENT_PIDS" ]; then

		(set -- $SSH_AGENT_PIDS
		 echo "Got $# agent processes" 1>&2)
		for SSH_AGENT_PID in $SSH_AGENT_PIDS; do
			SSH_AGENT_PID=`expr $SSH_AGENT_PID - 1`
			echo "Checking PID $SSH_AGENT_PID" 1>&2

			for S in /tmp/ssh-*/agent.$SSH_AGENT_PID; do
				if [ -n "$S" -a -e "$S" -a -S "$S" ]; then
						SSH_AUTH_SOCKS="${SSH_AUTH_SOCKS:+$SSH_AUTH_SOCKS
}$S"
				else
				P=`expr "${S##*.}" + 1`
						kill $P ${S##*.} >/dev/null 2>/dev/null
				fi
			done
		done
		unset P S
	fi

	if [ "${SSH_AUTH_SOCK-unset}" = unset ]; then

		(set -- $SSH_AUTH_SOCKS
		 echo "Got $# auth socks" 1>&2)

		for SSH_AUTH_SOCK in $SSH_AUTH_SOCKS; do
			[ -r "$SSH_AUTH_SOCK" -a -w "$SSH_AUTH_SOCK" ] && break
		done

		if ! [ -r "$SSH_AUTH_SOCK" -a -w "$SSH_AUTH_SOCK" ]  ; then
			eval `ssh-agent`
			echo "Started new SSH agent (PID ${SSH_AUTH_SOCK##*.})" 1>&2
		fi
	fi

	unset SSH_AGENT_PIDS SSH_AUTH_SOCKS
fi
