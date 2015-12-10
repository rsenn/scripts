is-a-tty () 
{ 
    eval "tty  0<&${1:-1} >/dev/null"
}
