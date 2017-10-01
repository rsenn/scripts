pkgsearch()
{
    ( EXCLUDE='-common -data -debug -doc -docs -el -examples -fonts -javadoc -static -tests -theme';
    for ARG in "$@";
    do
        sudo yum -y search "${ARG%%[!-A-Za-z0-9]*}" | ${GREP-grep} -i "$ARG[^ ]* : ";
    done | ${SED-sed} -n "/^[^ ]/ s,\..* : , : ,p" | ${GREP-grep} -vE "($(IFS='| '; set -- $EXCLUDE; echo "$*"))" | uniq )
}
