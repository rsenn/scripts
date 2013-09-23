grep-e-expr()
{ 
    echo "($(IFS="|
";  set -- $*; echo "$*" |sed 's,[()],.,g ; s,\[,\\[,g ; s,\],\\],g ; s,[.*],\\&,g'))"  
}
