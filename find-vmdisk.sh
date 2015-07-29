#!/bin/bash

CYGPATH=` which cygpath 2>/dev/null` 
NL="
"
#: ${CYGPATH:=true}

# append <var> <value>
append()
{
  eval "shift; ${1}=\${$1:+\${$1}\${NL}}\$*"
}

find_vmdisks()
{
	(IFS="
	 "
		EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"

		[ "$#" -le 0 ] && set -- *

		set -f 
		set find "$@" 

		CONDITIONS=

		for EXT in $EXTS; do
			 [ "$CONDITIONS" ] && append CONDITIONS -or
       append CONDITIONS -iname "*.$EXT${S}"
		done

		CONDITIONS="-type${NL}f${NL}-and${NL}(${NL}${CONDITIONS}${NL})" 
		set "$@"  $CONDITIONS 

    ${DEBUG-false} && echo "+ $@" 1>&2

		("$@" 2>/dev/null)  |sed -u 's,^\.\/,,'
	)
}

IFS="
"

while :; do
  case "$1" in
    -c|--completed) COMPLETED="true"; shift ;;
    -x|-d|--debug) DEBUG="true"; shift ;;
    *) break ;;
  esac
done

ARGS="$*"

set -- ''

if ! ${COMPLETED-false}; then
  set -- "$@" '*.part' '.!??'
fi

for S; do
  S="$S" find_vmdisks $ARGS
done
