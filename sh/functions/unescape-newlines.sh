unescape-newlines()
{
    ${SED-sed} -e ':start
  /\$/ {
  N
  s|\\\n[ \t]*||
  b start
  }' "$@"
}
