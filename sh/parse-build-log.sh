#!/bin/bash

IFS="
"
ws=" "
cr=""
ts="  "
nl="
"
vs="$nl"
sq="'"
dq="\""
sq="\`"
bs="\\"
fs="/"

setv() { 
    eval "shift;$1=\"\$*\""
}

pushv() { 
    eval "shift;$1=\"\${$1+\${$1}\${vs}}\$*\""
}

addpath() {
  cmd="${1}v"; N="$2"; shift 2; A=$*; A=${A//"\\"/"/"}
  $cmd "$N" "$A"
}

unshiftv() {
  eval "shift;$1=\"\$*\${$1+\${vs}\${$1}}\""
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
 (S="$1"; shift; IFS="$nl"; [ $# -gt 0 ] && exec <<<"$*"; ${SED-sed} "s|${S//\"/\\\"}|\n|g")
}

toupper() { 
 (C='tr "[[:lower:]]" "[[:upper:]]"'
  [ $# -gt 0 ] && C="$C <<<\"\$*\""
  eval "$C")
}

str_quote() { 
  case "$1" in 
    *["$cr$nl$ts"]*) echo "\$'`str_escape "$1"`'" 
                ;; 
             *"$sq"*) echo "\"`str_escape "$1"`\""  ;;
                  
                  *) echo "'$1'" ;;
  esac
}

str_escape() { 
 (S=$1
  case $S in 
    *[$cr$nl$ts"€"]*) S=${S//"$bs"/"$bs$BS"}; S=${S//"$cr"/"\r"}; S=${S//"$nl"/"\n"}; S=${S//"$ts"/"\t"}; S=${S//"$sq"/"\047"}; S=${S//""/"\001"}; S=${S//"€"/"\200"} ;;
    *$sq*) S=${S//"$bs"/"$bs$BS"}; S=${S//"$dq"/"$bs$dq"}; S=${S//"\$"/"$bs\$"}; S=${S//"$bq"/"$bs$bq"}  ;;
                  
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
 (O= cn=
  [ $# -gt 1 ] && cn='$(toupper "$vn")=\"'
  for vn; do V=$(getv "$vn" ";")
    C="O=\"\${O+\$O\$ovs}${cn}\${V}\\\"\""
    eval "$C"
  done
  echo "$O"
  var_s=" " var_dump O 1>&2 )
}


vifs=$'\t'
vifs=" "
myvars="args${nl}defines${nl}depfile${nl}deptarget${nl}includes${nl}libs${nl}opts${nl}outfile${nl}sysincludes"

while read -r line; do
 (IFS="$nl $cr$ts"
  case "$line" in
    *\"* | *\'* ) #line=${line//"("/"\\("}; line=${line//")"/"\\)"}; 
    eval "set -- "$line ;;
    *) set -- $line ;;
  esac || exit $?

  if [ $# -le 1 ]; then
    continue
  fi

  CMD="$1"
  shift
  unset $myvars

  mode="preproc${nl}compile${nl}assemble${nl}link"
  pos=0

  while [ $# -gt 0 ]; do
    pos=`expr $pos + 1`
    S=1
    case "$1" in
                 -I  | /I ) addpath unshift includes    "$2"         ; S=2 ;;
                 -I* | /I*) addpath unshift includes    "${1#?I}"          ;;
                -idirafter) addpath push    includes    "$2"         ; S=2 ;;
                  -isystem) addpath unshift sysincludes "$2"         ; S=2 ;;

                 -D  | /D ) addpath unshift defines     "$2"         ; S=2 ;;
                 -D* | /D*) addpath unshift defines     "${1#?D}"          ;;

            *.[Ll][Ii][Bb]) addpath push    libs        "$1"               ;;
                       -l*) pushv           libs        "$1"               ;;

                       -MF) setv            depfile     "$2"         ; S=2 ;;
                      -MF*) setv            depfile     "${1#?MF}"         ;;
                       -MT) setv            deptarget   "$2"         ; S=2 ;;
                      -MT*) setv            deptarget   "${1#?MT}"         ;;

                   -o | /o) setv            outfile     "$2"         ; S=2 ;;
                 -o* | /o*) setv            outfile     "${1#?o]}"         ;;
                   
                   -E | /E) mode="preproc"                                 ;;
                   -c | /c) mode="preproc${nl}compile${nl}assemble"        ;;
                   -S | /S) mode="preproc${nl}compile"                     ;;
                   
                   -* | /*) pushv opts_pos "$pos"
                            case "$1" in
                              *[\\/]*) addpath push opts "$1" ;;
                              *) pushv opts "$1" ;;
                            esac ;;
                            
                         *) pushv args_pos "$pos"
                            case "$1" in
                              *[\\/]*) addpath push args "$1" ;;
                              *) pushv args "$1" ;;
                            esac ;;
                  esac
    [ $((S)) -eq 1 ] && unset S
    shift $S
  done
  
  unset output 
#  output="cmd = $cmd"
 
# if ! (test -n "$CMD" && type "$CMD" >/dev/null 2>/dev/null); then
#    exit 1
# fi
# 
   pushv output "CMD=\"$CMD\"$(ovs=" " out_var $myvars)"

#    for arg in $args; do test -f "$arg" || exit 1; done   

  

echo "$output"

 )
done
