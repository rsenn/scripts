#!/bin/bash

WS=" "
CR=""
TS="	"
NL="
"
IFS="$NL"
VS="$NL"
IFS="$NL"
SQ="'"

pushv() { 
    eval "shift;$1=\"\${$1+\${$1}\${VS}}\$*\""
}

unshiftv() {
  eval "shift;$1=\"\$*\${$1+\${VS}\${$1}}\""
}

getv() {
 (S="$2"; eval "set -- \${$1}"; [ -n "$S" ] && implode "$S" <<<"$*" || echo "$*")
}

implode() {
 (unset D S; S="$1"; shift; C='D="${D+$D$S}$I"'
  if [ $# -gt 0 ]; then C="for I; do $C; done"
  else C="while read -r I; do $C; done"; fi
  eval "$C"; echo "$D")
}

explode() {
 (S="$1"; shift; IFS="$NL"; [ $# -gt 0 ] && exec <<<"$*"; sed "s|${S//\"/\\\"}|\n|g")
}

toupper() { 
 (C='tr "[[:lower:]]" "[[:upper:]]"'
  [ $# -gt 0 ] && C="$C <<<\"\$*\""
	eval "$C")
}

str_quote() { 
  case "$1" in 
		*["$CR$NL$TS"]*) echo "\$'`str_escape "$1"`'" ;; *"$SQ"*) echo "\"`str_escape "$1"`\"" ;; *) echo "'$1'" ;; esac
}

str_escape() { 
 (S=$1
  case $S in 
    *[$CR$NL$TS"€"]*) S=${S//"\\"/"\\\\"}; S=${S//""/"\\r"}; S=${S//"$NL"/"\\n"}; S=${S//"	"/"\\t"}; S=${S//""/"\\v"}; S=${S//"'"/"\047"}; S=${S//""/"\001"}; S=${S//"€"/"\200"} ;;
    *$SQ*) S=${S//"\\"/"\\\\"}; S=${S//"\""/"\\\""}; S=${S//"\$"/"\\\$"}; S=${S//"\`"/"\\\`"} ;; 
  esac
	echo "$S")
}

var_dump() { 
 (for N in "$@"; do
      N=${N%%=*}
      O=${O:+$O${var_s-${IFS%${IFS#?}}}}$N=`eval 'str_quote "${'$N'}"'`
  done
  echo "$O" )
}
if [ $# -gt 0 ]; then
  exec 0<"$1"
  shift
fi

out_var() {
 (O= CN=
  [ $# -gt 1 ] && CN='$(toupper "$VN") = '
  for VN; do V=$(getv "$VN" " | ")
		C="O=\"\${O+\$O\$OVS}${CN}${V}\""
		#echo "C='$C'" 1>&2
		eval "$C"
	done
	echo "$O"
	var_dump O 1>&2 )
}

VIFS=$'\t'
VIFS=" "
MYVARS="args
defines
depfile
deptarget
includes
libs
opts
outfile
sysincludes"

while read -r LINE; do
 (IFS="$NL $CR$TS"
  set -- $LINE

  if [ $# -le 1 ]; then
		continue
	fi

  CMD="$1"
  shift
  unset $MYVARS
#  args="$*"

	mode="preproc+compile+assemble+link"
  pos=0

  while [ $# -gt 0 ]; do
		pos=`expr $pos + 1`
		S=1
    case "$1" in
                 -I  | /I ) unshiftv includes    "$2"         ; S=2 ;; -I* | /I*) unshiftv includes    "${1#[-/]I}"       ;;

                 -D  | /D ) unshiftv defines     "$2"         ; S=2 ;; -D* | /D*) unshiftv defines     "${1#[-/]D}"       ;;

      *.[Ll][Ii][Bb] | -l*) pushv    libs        "$1"               ;; -MF) pushv    depfile     "$2"         ; S=2 ;;                       -MT) pushv    deptarget   "$2"         ; S=2 ;;                     -idirafter) pushv    includes    "$2"         ; S=2 ;;                 -isystem) unshiftv sysincludes "$2"         ; S=2 ;;                   -o | /o) pushv    outfile     "$2"         ; S=2 ;;                        -o* | /o*) pushv    outfile     "${1#[-/]o]}"      ;;                        -E | /E) mode="preproc"                          ;;                       
								   -c | /c) mode="preproc+compile+assemble"         ;;                        -S | /S) mode="preproc+compile"                  ;;                         -* | /*) pushv    opts        "$1"               ;; *) pushv args_pos "$pos"; pushv    args        "$1"               ;; esac
		[ $((S)) -eq 1 ] && unset S
    shift $S
  done
  
	OUTPUT="CMD = $CMD"

	pushv OUTPUT "$(OVS="${NL}${TS}" out_var $MYVARS)"
#	for VN in $MYVARS; do
#		pushv OUTPUT "${TS}$(out_var "$VN")"
##		V=$(getv "$VN" " | ")
##		[ -n "$V" ] || continue
##		pushv OUTPUT "${TS}$(toupper "$VN") = $V"
#	done

	echo "$OUTPUT"
 # echo "CMD=$CMD DEFINES=\"$(getv defines "$VIFS")\" DEPFILE=\"$(getv depfile "$VIFS")\" DEPTARGET=\"$(getv deptarget "$VIFS")\" INCLUDES=\"$(getv includes "$VIFS")\" LIBS=\"$(getv libs "$VIFS")\" OPTS=\"$(getv opts "$VIFS")\" OUTFILE=\"$(getv outfile "$VIFS")\" SYSINCLUDES=\"$(getv sysincludes "$VIFS")\""

 )
done
