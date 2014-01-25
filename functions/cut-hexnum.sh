cut-hexnum()
{ 
  sed 's,^\s*[0-9a-fA-F]\+\s*,,' "$@"
}
