chr2hex()
{
    echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"${2-0x}%02x\" \${ascii}]" | tclsh
}
