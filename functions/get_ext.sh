get_ext()
{ 
    set -- $( ( (set -- $(grep EXT.*= {find,locate,grep}-$1.sh -h 2>/dev/null |sed "s,EXTS=[\"']\?\(.*\)[\"']\?,\1," ); IFS="$nl"; echo "$*")|sed 's,[^[:alnum:]]\+,\n,g; s,^\s*,, ; s,\s*$,,';) |sort -fu);
    ( IFS=" ";
    echo "$*" )
}
