explode()
{
 (S="$1"; shift
  IFS="
";

  [ $# -gt 0 ] && exec <<<"$*"
  ${SED-sed} "s|${S//\"/\\\"}|\n|g"
 )
}
