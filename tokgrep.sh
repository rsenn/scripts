#!/usr/bin/env bash
# 
# match name token

charset='0-9A-Za-z_'$extrachars

unset pattern
unset replace
unset toklist
unset prev
count=0

check_chars() {
  eval local inval='${'$1"%%*[!${2-$charset}]*}"
  if [ -z "$inval" ]; then
    echo "${0##*/}: ${3+$3 }must contain characters from [${2-$charset}] only. ($inval)" 1>&2
    exit 1
  fi
}

subst_chars() {
  eval $1='${'$1"//$2/'$3'}"
}

num_refs() {
  local IFS="\\" ref=0 split
  set -- $pattern
  for split; do
    case $split in
      '('*) : $((ref++)) ;;
      ')'*) : $((ref--)) ;;
    esac
  done
  if test $ref != 0; then
    echo "${0##*/}: improperly balanced parenthesis in pattern" 1>&2
    exit 1
  fi
  return $(( ($# - 1) / 2 ))
}

shift_refs() {
  local IFS="\\" x=$1 out=$2
  set -- $replace
  eval $out='$1'
  shift
  for split; do
    local strip=${split#[0-9]}
    local n=${split%"$strip"}
    if test -z "$n" || test "$n" -gt "$nref"; then
      echo "${0##*/}: invalid reference near \\$split" 1>&2
      exit 1
    fi
    echo $out='"$'$out"\\"$((n+x))"$strip\""
    eval $out='"$'$out"\\"$((n+x))'$strip"'
  done
}
count() {
        echo $#
}
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}


main() {

  opts=
  ntoks=0
  multitok=false
  
  for arg; do
    [ "$debug" = "true" ] && echo "arg=\"$arg\" ntoks=$ntoks" 1>&2
    [ "$arg" = "--" ] && break
    case "$arg" in
      -x) debug=true ;;
      -*) ;;
      "--" | -- | \-\-) #multitok=true;
        break  2 ;;
      *) ntoks=$((ntoks+1)) ;;
    esac
  done
  
  [ "$debug" = "true" ] && echo "multitok=$multitok" 1>&2
  #if [ "${multitok:-false}" = false ]; then
  #  ntoks=1
  #fi
  
  while :; do
    case "$1" in
      -x) debug=true; shift ;;
      -*) opts="${opts:+$opts${IFS}}$1"; shift ;;
      *) break ;;
    esac
  done
  
  if "${debug:-false}"; then
    echo "@=$@" 1>&2 
    echo "ntoks=$ntoks" 1>&2 
  fi  

  for arg; do
    if [ "$((count++))" = 0 ]; then
      set --
    fi

    if [ -n "${prev+set}" ]; then
      set -- "$@" "$prev" "$arg"
      unset prev
      continue
    fi

    case $arg in
    
      -x)
        debug=true
        continue
      ;;
      -e|-f|-l*|-m|-d|-D|-A|-B|-C|-r*) 
        prev=$arg
        continue
      ;;
      
      -*) 
        set -- "$@" "$arg" 
      ;;
      
      *)
        if [ "$(count $tokens)" -lt $((ntoks)) ]; then
          pushv tokens "$arg"
          pattern=$arg
          check_chars pattern "$charset.?*+()" pattern
          subst_chars pattern '.' "[$charset]"
          subst_chars pattern '(' "\\("
          subst_chars pattern ')' "\\)"

          toklist="${toklist:+$toklist|}[^$charset]$pattern[^$charset]|[^$charset]$pattern\$|^$pattern[^$charset]|^$pattern\$"
          set -- "$@" -E -e "($toklist)"
        else
          pushv files "$arg"
          set -- "$@" -- "$arg"
        fi
      ;;
    esac
    
  done
  
  set -- $opts -E -e "($toklist)" --  $files
  
  if "${debug:-false}"; then
  echo "@=$@" 1>&2
    set -x
  fi
  exec grep $opts "$@"
}
#set -x
main "$@"
