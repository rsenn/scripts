video-height()
{ 
    ( for ARG in "$@";
    do
        [ $# -gt 1 ] && PFX="$ARG: " || unset PFX;
        mminfo "$ARG" | sed -n "s|^Height=|$PFX|p";
    done )
}
