list-7z()
{
  (FILTER="sed -n '/^\\s*Date\\s\\+Time\\s\\+Attr/ { 
    :lp	
      N	
      \$! b lp	
       s/[^\\n]*files[^\\n]*folders\$//	
      s/\\n[- \\t]*\\n/\\n/g	
      s/\\n[.0-9][-.0-9]\\+\\s\\+[.0-9:]\\+\\s\\+[^ \\t]*[.[:alnum:]][^ \\t]*\\+\\s\\s*\\([.0-9]\\+\\)\\s\\s/\\n  /g	
      s/\\n\\s\\+[.0-9]\\+\\s\\+[.0-9]\\+/\\n  /g	
      s/\\n\\s\\+[.0-9]\\+\\s\\s*/\\n  /g	
      s/\\n\\s\\+/\\n/g	
      s/^\\s*Date\\s\\+Time[^\\n]*//	
      s/\\n[^/]*files[^/]*folders\$//	
      s/\\n\\s*\\n\\?\$//
      s/^\\n\\?\\s*\\n//
      p	
  }'"
  [ $# -gt 1 ] && FILTER="$FILTER | addprefix \"\$ARG: \""
  for ARG; do
    7z l "$ARG" | eval "$FILTER"
   done)
}
