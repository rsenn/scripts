explode()
{
 (S="$1"; shift
  IFS="
";

  [ $# -gt 0 ] && exec <<<"$*"
  sed "s|${S//\"/\\\"}|\n|g"
 )
}
