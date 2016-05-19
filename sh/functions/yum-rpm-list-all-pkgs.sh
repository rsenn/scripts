yum-rpm-list-all-pkgs()
{
  require rpm

  yum list all >yum.list
  #${SED-sed} -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1,p' <yum.list >pkgs.list
  ${SED-sed} -n 's,^\([^ ]\+\)\(\.[^.]\+\)\s.*,\1\2,p' <yum.list >pkgs.list
  #rpm_list |sort |${SED-sed} 's,\.[^.]\+$,, ; s,\.[^.]\+$,, ; s,-[^-]\+$,, ; s,-[^-]\+$,,' >rpm.list
  rpm_list |sort |${SED-sed}  "s|-\([^-]\+\)-\([^-]\+\)\.\([^.]\+\)\.\([^.]\+\)$|.\4|" >rpm.list

  rpm_expr=^$(grep-e-expr $(<rpm.list))

  ${GREP-grep -a --line-buffered --color=auto} -v -E "$rpm_expr\$" <pkgs.list >available.list

  (set -x; wc -l {yum,rpm,pkgs,available}.list)
}
