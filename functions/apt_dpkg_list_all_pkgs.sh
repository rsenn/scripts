apt-dpkg-list-all-pkgs()
{
  require apt
  require dpkg

  apt_list >apt.list
  dpkg_list >dpkg.list

  dpkg_expr=^$(grep-e-expr $(<dpkg.list))

  awkp <apt.list >pkgs.list
  grep -v -E "$dpkg_expr\$" <pkgs.list  >available.list

  (set -x; wc -l {apt,dpkg,pkgs,available}.list)
}
