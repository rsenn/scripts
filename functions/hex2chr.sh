hex2chr()
{ 
    echo "puts -nonewline [format \"%c\" 0x$1]" | tclsh
}
