debug()
{
    [ "$DEBUG" = true ] && echo "DEBUG: $@" 1>&2
}
