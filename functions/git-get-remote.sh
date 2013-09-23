git-get-remote()
{
  git remote -v | sed "s,\s\+, ,g ; s,\s*([^)]*),," |uniq
}