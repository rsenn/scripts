apt-dpkg-list-all-pkgs()
{
  NL="
"
  require apt
  require dpkg

  apt_list >apt.list
  dpkg_list >dpkg.list

  dpkg_expr=^$(grep-e-expr $(<dpkg.list))

  awkp <apt.list >pkgs.list
  ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -v -E "$dpkg_expr\$" <pkgs.list  >available.list

  (set -x; wc -l {apt,dpkg,pkgs,available}.list)
}
