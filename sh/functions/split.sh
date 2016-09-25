split()
{
    local _a__ _s__="$1";
    for _a__ in $_s__;
    do
        shift;
        eval "$1='`echo "$_a__" | ${SED-sed} "s,','\\\\'',g"`'";
    done
}
