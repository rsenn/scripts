firstletter()
{
    ( for ARG in "$@";
    do
        REST=${ARG#?};
        echo "${ARG%%$REST}";
    done )
}
