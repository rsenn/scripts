msg()
{ 
    echo "${me:+$me: }$@" 1>&2
}
