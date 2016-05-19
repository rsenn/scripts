submatch()
{
    local arg exp src dst result=$1 && shift;
    for arg in "$@";
    do
        exp="${arg#*=}";
        dst="${arg%$exp}";
        dst="${dst%=}";
        src="${exp%%[!A-Za-z_]*}";
        exp="${exp#$src}";
        eval ${dst:=$result}='${'${src:=$result}$exp'}';
    done
}
