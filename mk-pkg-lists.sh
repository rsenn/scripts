#!/bin/bash

. require.sh

. bash_functions.sh 

IFS="
"

implode() {
 (unset DATA SEPARATOR;
  SEPARATOR="$1"; shift
  CMD='DATA="${DATA+$DATA$SEPARATOR}$LINE"'
  if [ $# -gt 1 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD"
  echo "$DATA")
}

grep_e_expr() {
  implode "|" "$@" |sed 's,[()],&,g ; s,\[,\\[,g ; s,\],\\],g ; s,[.*\\],\\&,g ; s,.*,(&),'
}

apt_dpkg_list_all_pkgs()
{
  require apt
  require dpkg

  apt_list >apt.list
  dpkg_list >dpkg.list

  dpkg_expr=^$(grep_e_expr $(<dpkg.list))

  awkp <apt.list |sort >pkgs.list
  grep -v -E "$dpkg_expr\$" <pkgs.list  >available.list

  (set -x; wc -l {apt,dpkg,pkgs,available}.list)
}

yum_rpm_list_all_pkgs()
{
  require rpm
  require yum

  yum_list  >yum.list
  #sed -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <yum.list >pkgs.list
  sed -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1\2,p' <yum.list |sed 's,\s*$,,' >pkgs.list
  #rpm_list |sort |sed 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  rpm_list |sort |sed  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

	set -- $(<rpm.list)

	rpm_exprfile=rpm.expr
	trap 'rm -rf "$rpm_exprfile"' EXIT
	echo "^$(grep_e_expr "$@")\$" >"$rpm_exprfile"

  grep -v -E -f "$rpm_exprfile" <pkgs.list >available.list

  (set -x; wc -l {yum,rpm,pkgs,available}.list)
}

require distrib

case $(distrib_get id) in
  [Ff]edora) yum_rpm_list_all_pkgs ;;
  [Dd]ebian|[Uu]buntu) apt_dpkg_list_all_pkgs ;;
*) echo "No such distribution $(distrib_get id)" 1>&2 ;;
esac
