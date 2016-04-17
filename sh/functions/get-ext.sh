get-ext()
{
  NL="
"
    set -- $( ( (set -- $(${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} EXT.*= {find,locate,grep}-$1.sh -h 2>/dev/null |${SED-sed} "s,EXTS=[\"']\?\(.*\)[\"']\?,\1," ); IFS="$nl"; echo "$*")|${SED-sed} 's,[^[:alnum:]]\+,\n,g; s,^\s*,, ; s,\s*$,,';) |sort -fu);
    ( IFS=" ";
    echo "$*" )
}
