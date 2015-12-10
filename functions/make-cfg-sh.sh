make-cfg-sh() { 
 (for ARG in "${@:-./configure}"; do
     
  "$ARG" --help=recursive 2>&1 |sed -n '1 s,.*,./configure \\,p; /--help/d; /--cache-file/d; /--srcdir/d; /^\s*--/   {
/-[[:upper:]]/q ; s|^\s*||; s|\s.*||; s|=\(.*\)|=\${\1}|; s|.*|  & \\|;   p
}
'|sed '$ s,.*,  "$@",'
  done)
}
