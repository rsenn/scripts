list-path()
{
  (IFS=":"; find $PATH -maxdepth 1 -mindepth 1 -not -type d)
}
