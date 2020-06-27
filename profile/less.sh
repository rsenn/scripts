# less initialization script (sh)
LESSCHARSET=utf-8
LESS=-R

export LESS LESSCHARSET
[ -x /usr/bin/lesspipe.sh ] && export LESSOPEN="${LESSOPEN-||/usr/bin/lesspipe.sh %s}"
