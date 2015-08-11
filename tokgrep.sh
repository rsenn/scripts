#!/usr/bin/env bash
# 
# match name token

charset='0-9A-Za-z_'$extrachars

unset pattern
unset replace
unset script
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

main() {

  opts=
  for arg; do 
    case "$arg" in
      --) multitok=true; break ;;
    esac
  done
  
  while :; do
    case "$1" in
      -*) opts="${opts:+$opts${IFS}}$1"; shift ;;
      *) break ;;
    esac
  done
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
      -e|-f|-l*|-m|-d|-D|-A|-B|-C|-r*) 
        prev=$arg
        continue
      ;;
      
      -*) 
        set -- "$@" "$arg" 
      ;;
      
      *)
        if test -z "${pattern+set}"; then
          pattern=$arg
          check_chars pattern "$charset.?*+()" pattern
          subst_chars pattern '.' "[$charset]"
          subst_chars pattern '(' "\\("
          subst_chars pattern ')' "\\)"

          script="([^$charset]$pattern[^$charset]|[^$charset]$pattern\$|^$pattern[^$charset]|^$pattern\$)"
          set -- "$@" -E -e "$script"
        else
          set -- "$@" "$arg"
        fi
      ;;
    esac
    
  done

  exec grep $opts "$@"
}
#set -x
main "$@"
