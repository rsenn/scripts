addsuffix()
{ 
    ( while read -r LINE; do
        echo "${LINE}$1";
    done )
}
