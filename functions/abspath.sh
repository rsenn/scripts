abspath()
{ 
    if [ -e "$1" ]; then
        local dir=`dirname "$1"` && dir=`absdir "$dir"`;
        echo "${dir%/.}/${1##*/}";
    fi
}
