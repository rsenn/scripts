verbose()
{
    local msg="$*" a=`eval "echo \"\${$#}\""` IFS="
";
    if [ "$#" = 1 ]; then
        a=1;
    fi;
    if ! [ "$a" -ge 0 ]; then
        a=0;
    fi 2> /dev/null > /dev/null;
    if [ "$verbosity" -ge "$a" ]; then
        msg "${msg%?$a}";
    fi
}
