video-width()
{
    ( for ARG in "$@";
    do
        [ $# -gt 1 ] && PFX="$ARG: " || unset PFX;
        mminfo "$ARG" | sed -n "s|^Width=|$PFX|p";
    done )
}
