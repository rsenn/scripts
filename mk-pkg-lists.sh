#!/bin/bash

. require.sh

. bash_functions.sh 

IFS="
"

exec 9>&1

verbose() {
  echo $* 1>&9
}

cut_ver () 
{ 
    cat "$@" | cut_trailver | sed 's,[-.]rc[[:alnum:]][^-.]*,,g ;; s,[-.]b[[:alnum:]][^-.]*,,g ;; s,[-.]git[_[:alnum:]][^-.]*,,g ;; s,[-.]svn[_[:alnum:]][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]][^-.]*,,g ;; s,[-.]beta[_[:alnum:]][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]][^-.]*,,g ;; s,[-.]a[_[:alnum:]][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]][^-.]*,,g' | sed 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' | sed 's,\.\(P\)\?[0-9][_+[:digit:]]*\.,.,g' | sed 's,[.-][0-9][_+[:alnum:]]*$,,g ;; s,[.-][0-9][_+[:alnum:]]*\([-.]\),\1,g' | sed 's,[-_.][0-9]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[0-9][_+[:digit:]]*\(-.\),\5,g' | sed 's,-[0-9][._+[:digit:]]*$,, ;;  s,-[0-9][._+[:digit:]]*$,,' | sed 's,[.-][0-9][_+[:alnum:]]*$,,g ;; s,[.-][0-9]*\(rc[0-9]\)\?\(b[0-9]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[0-9]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[0-9][_+[:alnum:]]*\.,.,g' | sed 's,\.[0-9][^.]*\.,.,g'
}
cut_trailver () 
{ 
    cat "$@" | sed 's,-[0-9][^-.]*\(\.[0-9][^-.]*\)*$,,'
}

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

  verbose "Creating yum.list"  
  yum_list  >yum.list
  #sed -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <yum.list >pkgs.list
  verbose "Creating pkgs.list"  
  sed -e 's,\s*$,,' -e  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" <yum.list >pkgs.list
  #rpm_list |sort |sed 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  verbose "Creating rpm.list"  
  rpm_list |sed 's|-[0-9].*\.fc[0-9]\+||' >rpm.list
  #rpm_list |sort |sed  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

	set -- $(<rpm.list)

	rpm_exprfile=rpm.expr
	trap 'rm -rf "$rpm_exprfile"' EXIT

  for x; do 
    echo "\|^${x}\$|d" 
  done >"$rpm_exprfile"

  #for RPM; do
  #  grep "^${RPM}\$" rpm.list 
  #done >available.list


  verbose "Creating available.list"  
  sed -f "$rpm_exprfile" pkgs.list >available.list

  (set -x; wc -l {yum,rpm,pkgs,available}.list)
}

require distrib

case $(distrib_get id) in
  [Ff]edora) yum_rpm_list_all_pkgs ;;
  [Dd]ebian|[Uu]buntu) apt_dpkg_list_all_pkgs ;;
*) echo "No such distribution $(distrib_get id)" 1>&2 ;;
esac
