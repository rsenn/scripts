list-path()
{
  (IFS=":"; eval 'find $'${PATHVAR:-PATH}' -maxdepth 1 -mindepth 1 -not -type d') 2>/dev/null
}
