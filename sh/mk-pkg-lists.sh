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
    cat "$@" | cut_trailver | ${SED-sed} 's,[-.]rc[[:alnum:]][^-.]*,,g ;; s,[-.]b[[:alnum:]][^-.]*,,g ;; s,[-.]git[_[:alnum:]][^-.]*,,g ;; s,[-.]svn[_[:alnum:]][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]][^-.]*,,g ;; s,[-.]beta[_[:alnum:]][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]][^-.]*,,g ;; s,[-.]a[_[:alnum:]][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]][^-.]*,,g' | ${SED-sed} 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' | ${SED-sed} 's,\.\(P\)\?[0-9][_+[:digit:]]*\.,.,g' | ${SED-sed} 's,[.-][0-9][_+[:alnum:]]*$,,g ;; s,[.-][0-9][_+[:alnum:]]*\([-.]\),\1,g' | ${SED-sed} 's,[-_.][0-9]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[0-9][_+[:digit:]]*\(-.\),\5,g' | ${SED-sed} 's,-[0-9][._+[:digit:]]*$,, ;;  s,-[0-9][._+[:digit:]]*$,,' | ${SED-sed} 's,[.-][0-9][_+[:alnum:]]*$,,g ;; s,[.-][0-9]*\(rc[0-9]\)\?\(b[0-9]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[0-9]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[0-9][_+[:alnum:]]*\.,.,g' | ${SED-sed} 's,\.[0-9][^.]*\.,.,g'
}
cut_trailver () 
{ 
    cat "$@" | ${SED-sed} 's,-[0-9][^-.]*\(\.[0-9][^-.]*\)*$,,'
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
  implode "|" "$@" |${SED-sed} 's,[()],&,g ; s,\[,\\[,g ; s,\],\\],g ; s,[.*\\],\\&,g ; s,.*,(&),'
}

apt-dpkg-list-all-pkgs()
{
  require apt
  require dpkg

  apt_list -q >apt.list
  dpkg_list >dpkg.list

	dpkg_exprfile=dpkg.expr
	trap 'rm -rf "$dpkg_exprfile"' EXIT

	for x in $(<dpkg.list); do
    echo "\|^${x}\$|d" 
  done >"$dpkg_exprfile"

  #dpkg_expr=^$(grep_e_expr $(<dpkg.list))

  awkp <apt.list |sort >pkgs.list
  ${SED-sed} -f "$dpkg_exprfile" pkgs.list >available.list
	#grep -v -E "$dpkg_expr\$" <pkgs.list  >available.list

  (set -x; wc -l {apt,dpkg,pkgs,available}.list)
}

yum-rpm-list-all-pkgs()
{
  require rpm
  require yum

  verbose "Creating yum.list"  
  yum_list  >yum.list
  #${SED-sed} -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <yum.list >pkgs.list
  verbose "Creating pkgs.list"  
  ${SED-sed} -e 's,\s*$,,' -e  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" <yum.list >pkgs.list
  #rpm_list |sort |${SED-sed} 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  verbose "Creating rpm.list"  
  rpm_list |${SED-sed} 's|-[0-9].*\.fc[0-9]\+||' >rpm.list
  #rpm_list |sort |${SED-sed}  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

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
  ${SED-sed} -f "$rpm_exprfile" pkgs.list >available.list

  (set -x; wc -l {yum,rpm,pkgs,available}.list)
}

zypper_rpm_list_all_pkgs() {
  require rpm
  require zypper

  verbose "Creating zypper.list"  
  zypper_list  >zypper.list
  #${SED-sed} -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <zypper.list >pkgs.list
  verbose "Creating pkgs.list"  
  ${SED-sed} -e 's,\s*$,,' -e  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|-\1.\4|" <zypper.list >pkgs.list
  #rpm_list |sort |${SED-sed} 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  verbose "Creating rpm.list"  
  rpm_list |${SED-sed} 's|-[0-9].*\.fc[0-9]\+||' >rpm.list
  #rpm_list |sort |${SED-sed}  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

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
  ${SED-sed} -f "$rpm_exprfile" pkgs.list >available.list

  (set -x; wc -l {zypper,rpm,pkgs,available}.list)
}

yaourt_pacman_list_all_pkgs() {

    type $YAOURT 2>/dev/null >/dev/null && YAOURT=yaourt || YAOURT=:
	for OPT in e d; do
		$SUDO pacman -Q${OPT} 
		$YAOURT -Q${OPT} 
  done \
		|${SED-sed} 's|\s\+(.*||' | sort -k1,2 -V -u >installed.list

  {
		$YAOURT -Sl
		$SUDO pacman -Sl
  } | ${SED-sed} 's,^[/ ]*[/ ],, ; s,\s\+[\[(].*,,' |sort -u | ${SED-sed} 's,/, , ; s,^[^ ]* ,,' |sort -V -u >pkgs.list
  #} | ${SED-sed} 's,^[ /]\+[ /],, ; s,\s\+[\[(].*,, ; s, .*,,' |sort -k1,2 -V -u >pkgs.list

  set -- $(<installed.list)

	exprfile=rpm.expr
	trap 'rm -rf "$exprfile"' EXIT

  for x; do 
    echo "\|^${x}\$|d" 
  done >"$exprfile"

	${SED-sed} -f "$exprfile" pkgs.list >available.list

}
require distrib

if type sudo 2>/dev/null >/dev/null; then
  SUDO=sudo
fi

case $(distrib_get id) in
  [Mm][Ss][Yy][Ss]) CMD=yaourt_pacman_list_all_pkgs ;;
  [Ff]edora) YUM_cmd=dnf; CMD=yum-rpm-list-all-pkgs ;;
  [Dd]ebian|[Uu]buntu) CMD=apt-dpkg-list-all-pkgs ;;
  openS[Uu]SE*|opensuse*) CMD=zypper_rpm_list_all_pkgs  ;;
  [Aa]rch*|[Mm]anjaro*) CMD=yaourt_pacman_list_all_pkgs  ;;
*) echo "No such distribution $(distrib_get id)" 1>&2 ;;
esac

#[ -n "$CMD" ] && (set +x; $CMD)
[ -n "$CMD" ] && $CMD
