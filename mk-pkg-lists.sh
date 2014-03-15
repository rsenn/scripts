#!/bin/bash

. require.sh

. bash_functions.sh 

apt_dpkg_list_all_pkgs()
{
  require apt
  require dpkg

  apt_list >apt.list
  dpkg_list >dpkg.list

  dpkg_expr=^$(grep-e-expr $(<dpkg.list))

  awkp <apt.list |sort >pkgs.list
  grep -v -E "$dpkg_expr\$" <pkgs.list  >available.list

  (set -x; wc -l {apt,dpkg,pkgs,available}.list)
}

yum_rpm_list_all_pkgs()
{
  require rpm

  yum list all >yum.list
  #sed -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <yum.list >pkgs.list
  sed -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1\2,p' <yum.list >pkgs.list
  #rpm_list |sort |sed 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  rpm_list |sort |sed  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

  rpm_expr=^$(grep-e-expr $(<rpm.list))

  grep -v -E "$rpm_expr\$" <pkgs.list >available.list

  (set -x; wc -l {yum,rpm,pkgs,available}.list)
}

require distrib

case $(distrib_get id) in
  [Ff]edora) yum_rpm_list_all_pkgs ;;
  [Dd]ebian) apt_dpkg_list_all_pkgs ;;
esac
