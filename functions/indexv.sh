indexv()
{
 (shiftv "$@"
  eval "echo \"\${$1%%[\$IFS]*}\"")
}
