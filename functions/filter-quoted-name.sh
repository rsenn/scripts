filter-quoted-name()
{
  sed -n "s|.*\`\([^']\+\)'.*|\1|p"
}
