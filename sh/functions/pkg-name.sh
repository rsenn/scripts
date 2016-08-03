pkg-name()
{
    ( for ARG in "$@";
    do
        ARG=${ARG%.t?z};
        ARG=${ARG%.[tdr][aegpx][rbmz]*};
        ARG=${ARG%.*};
        echo "${ARG%%-[0-9]*}";
    done )
}
