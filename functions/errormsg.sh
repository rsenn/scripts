errormsg()
{ 
    local retcode="${2:-$?}";
    msg "ERROR: $@";
    return "$retcode"
}
