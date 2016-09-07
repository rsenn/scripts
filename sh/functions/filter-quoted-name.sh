filter-quoted-name()
{
  ${SED-sed} -n "s|.*\`\([^']\+\)'.*|\1|p"
}
