unescape-newlines()
{
    sed -e ':start
  /\$/ {
  N
  s|\\\n[ \t]*||
  b start
  }' "$@"
}
