grep-v-unneeded-pkgs()
{
  grep -v -E "(-debuginfo\$|-devel\$|-doc\$|-javadoc\$|-fonts\$|-static\$|-common\$|-plugin\$|-docs\$|-el\$|-data\$|-examples\$)"
}
