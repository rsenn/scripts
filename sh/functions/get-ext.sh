get-ext()
{
    set -- $( ( (set -- $(${GREP-grep} EXT.*= {find,locate,grep}-$1.sh -h 2>/dev/null |${SED-sed} "s,EXTS=[\"']\?\(.*\)[\"']\?,\1," ); IFS="$nl"; echo "$*")|${SED-sed} 's,[^[:alnum:]]\+,\n,g; s,^\s*,, ; s,\s*$,,';) |sort -fu);
    ( IFS=" ";
    echo "$*" )
}
