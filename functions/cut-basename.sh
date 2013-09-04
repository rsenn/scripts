cut-basename()
{ 
    sed -u 's,/[^/]*/\?$,,'
}
