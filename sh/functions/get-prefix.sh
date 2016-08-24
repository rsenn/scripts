get-prefix () 
{ 
    cygpath -a $(${CC:-gcc} -print-search-dirs |sed -n 's,.*:\s\+=\?,,; s,/bin.*,,p ; s,/lib.*,,p' |head -n1)
}
