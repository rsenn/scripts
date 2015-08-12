#!/bin/sh

IFS="
$IFS"

# ---------------------------------------------------------------------------
implode() {
 (IFS="$1$IFS"
  shift
  if [ $# -le 0 ]; then
    while read -r LINE; do
      set -- "$@" "$LINE"
    done
  fi
  echo "$*")
}

# ---------------------------------------------------------------------------
output_existing() {
 (for ARG; do
    if [ -e "$ARG" ]; then
      echo "$ARG"
    fi
  done)
}
# ---------------------------------------------------------------------------
output_first_existing() {
 (for ARG; do
    if [ -e "$ARG" ]; then
      echo "$ARG"
      exit
    fi
  done)
}

# ---------------------------------------------------------------------------
get_mingw_paths() {
  SUBST="{$(df -l|sed 1d|awk '{ print $6 }'|implode ",")}/*mingw*{,/*,/*/*}/bin/*gcc{,.exe}"
  eval set -- $SUBST
  output_existing "$@"
}

# ---------------------------------------------------------------------------
get_mingw_basedir() {
(BASEDIR="${1%/bin*}"
  [ "$BASEDIR" = "$1" ] && BASEDIR="${1%/lib*}"
  eval set -- $BASEDIR{/mingw[36][24],}/ 
  output_first_existing "${@%/}")
}

# ---------------------------------------------------------------------------
get_mingw_dir() {
eval set -- $(get_mingw_basedir "$1"){,/mingw[36][24]}${2:+/$2}
  output_first_existing "$@"
#  eval "ls -1 -d  -- \"\$(get_mingw_basedir \"\$1\")\"{,/mingw[36][24]}"${2:+/$2} 2>/dev/null
}

# ---------------------------------------------------------------------------
get_mingw_sysroot() {
  get_mingw_dir "$1" "{sys*root,opt}"${2:+/$2}
}
# ---------------------------------------------------------------------------
get_mingw_machinedir() {
 (eval set --  $(get_mingw_dir "$1" "$(get_mingw_machine "$1")")${2:+/$2}
  output_first_existing "$@")
}

# ---------------------------------------------------------------------------
get_mingw_libgcc() {
 (get_mingw_machinedir "$1" "lib{64,}/libgcc_s*.dll")
}


# ---------------------------------------------------------------------------
get_mingw_threadtype() {
 (BASEDIR=$(get_mingw_basedir "$1")
  BASEDIR=${BASEDIR%/mingw[36][24]}
  case "${BASEDIR##*/}" in
    *posix*) echo "posix" ;;
    *win32*) echo "win32" ;;
  esac)
}

# ---------------------------------------------------------------------------
get_mingw_exceptiontype() {
 LIBGCC_S=$(get_mingw_machinedir "$1" "lib{64,}/libgcc_s*.dll")
 case "$LIBGCC_S" in
   *_sjlj*) echo "sjlj" ;;
   *_seh*) echo "seh" ;;
   *_dw2*) echo "dwarf" ;;
 esac
}

# ---------------------------------------------------------------------------
get_mingw_output() {
 (BASEDIR=$(get_mingw_basedir "$1")
  shift
  IFS="

	"
  set -- $("$BASEDIR/bin/gcc" "$@" | sed "s|^\\.\\./|${BASEDIR}/|")
  echo "$*")
}

# ---------------------------------------------------------------------------
get_mingw_version() { get_mingw_output "$1" -dumpversion; }
# ---------------------------------------------------------------------------
get_mingw_machine() { get_mingw_output "$1" -dumpmachine; }
# ---------------------------------------------------------------------------
get_mingw_specs() { get_mingw_output "$1" -dumpspecs; }
# ---------------------------------------------------------------------------
get_mingw_searchdirs() { get_mingw_output "$1" -print-search-dirs; }
# ---------------------------------------------------------------------------
get_mingw_libgccfilename() { get_mingw_output "$1" -print-libgcc-file-name; }

PREVDIR=

for CC in $(get_mingw_paths); do
  LIBGCC_S=$(get_mingw_libgcc "$CC")
  CCDIR=${CC%/*}
  
  if [ "$CCDIR" != "$PREVDIR" ]; then
    echo "$CC" "$(get_mingw_machine "$CC")-$(get_mingw_version "$CC")-$(get_mingw_threadtype "$CC")-$(get_mingw_exceptiontype "$CC")"
  fi
  
  PREVDIR="$CCDIR"
done


