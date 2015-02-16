#!/bin/bash
# 
# substitute name token
# 
# $Id: $

charset=$extrachars'0-9A-Za-z_' count=0

unset pattern replace script prev

check_chars() 
{
  eval inval='${'$1"%%*[!${2-$charset}]*}"
  
  if [ -z "$inval" ]; then
    echo "${0##*/}: ${3+$3 }must contain characters from [${2-$charset}] only. ($inval)" 1>&2
    exit 1
  fi
}

subst_chars()
{
  eval $1='${'$1"//$2/'$3'}"
}

num_refs()
{
  local IFS="\\" ref=0 split

  set -- $pattern

  for split; do
    case $split in
      '('*) ref=`expr $ref + 1` ;;
      ')'*) ref=`expr $ref - 1` ;;
    esac
  done

  if [ "$ref" != 0 ]; then
    echo "${0##*/}: improperly balanced parenthesis in pattern" 1>&2
    exit 1
  fi

  return $(( ($# - 1) / 2 ))
}

shift_refs()
{
  local IFS="\\" x=$1 out=$2
  set -- $replace
  eval $out='$1'
  shift
  for split; do
    local strip=${split#[0-9]}
    local n=${split%"$strip"}
    if test -z "$n" || [ "$n" -gt "$nref" ]; then
      echo "${0##*/}: invalid reference near \\$split" 1>&2
      exit 1
    fi
    echo $out='"$'$out"\\"$((n+x))"$strip\""
    eval $out='"$'$out"\\"$((n+x))'$strip"'
  done
}

for arg; do
  if [ "$count" = 0 ]; then
    set --
  fi

  count=`expr $count + 1`

  if test -n "${prev+set}"; then
    set -- "$@" "$prev" "$arg"
    unset prev
    continue
  fi

  case $arg in
    -e|-f|-l) 
      prev=$arg
      continue
    ;;
    
    -*) 
      set -- "$@" "$arg" 
    ;;
    
    *)
      if test -z "${pattern+set}"; then
        pattern=$arg
#        check_chars pattern "$charset.?*+()" pattern
        subst_chars pattern '.' "[$charset]"
        subst_chars pattern '(' "\\("
        subst_chars pattern ')' "\\)"
        num_refs; nref=$?
      elif test -z "${replace+set}"; then
        replace=$arg
        check_chars replace "$charset\\\\0-9"
        shift_refs 1 shifted
        script="/$pattern/ {
          s,\([^$charset]\)$pattern\([^$charset]\),\\1$shifted\\$((nref+2)),g
          s,\([^$charset]\)$pattern\$,\\1$shifted,g
          s,^$pattern\([^$charset]\),$replace\\$((nref+1)),g
          s,^$pattern\$,$replace,g
        }"
        set -- "$@" -e "$script"
      else
        set -- "$@" "$arg"
      fi
    ;;
  esac
  
done
#set -x
exec sed "$@"
