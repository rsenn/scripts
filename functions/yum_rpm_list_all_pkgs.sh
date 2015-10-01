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
