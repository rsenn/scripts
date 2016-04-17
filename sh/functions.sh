if (id) > /dev/null 2>&1; then
	userid() {
		id $1 | tr ' =()' '\n:::' | ${GREP-grep -a --line-buffered --color=auto} ^uid: | cut -d: -f2
	}
	usergid() {
		id $1 | tr ' =()' '\n:::' | ${GREP-grep -a --line-buffered --color=auto} ^gid: | cut -d: -f2
	}
	username() {
		id $1 | tr ' =()' '\n:::' | ${GREP-grep -a --line-buffered --color=auto} ^uid: | cut -d: -f3
	}
	userpgroup() {
		id $1 | tr ' =()' '\n:::' | ${GREP-grep -a --line-buffered --color=auto} ^gid: | cut -d: -f3
	}
	isuser() {
		id $1 >/dev/null 2>&1
	}
else
	echo 'ERROR: cannot determine user information.'
	echo 'It means you do not have id command in your path.'
	exit 1
fi

chowner() {
	chown $1:`userpgroup $1` $2
}

unamecheck() {
	test "`username`" = "$1"
}

uidcheck() {
	test "`userid`" = "$1"
}

die() {
	echo $@ >&2
	exit 1
}
