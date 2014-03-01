diff_plus_minus()
{ 
    local IFS="$newline" d=$(diff -x .svn -ruN "$@" |
      sed -n -e "/^[-+][-+][-+]\s\+$1/d"                -e "/^[-+][-+][-+]\s\+$2/d"                -e '/^[-+]/ s,^\(.\).*$,\1, p' 2>/dev/null);
    IFS="-$newline ";
    eval set -- $d;
    local plus=$#;
    IFS="+$newline ";
    eval set -- $d;
    local minus=$#;
    echo "+$plus" "-$minus"
}
