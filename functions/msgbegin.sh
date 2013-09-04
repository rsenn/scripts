msgbegin()
{ 
    echo -n "${me:+$me: }$@" 1>&2
}
