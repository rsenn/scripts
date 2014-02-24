pkgsearch()
{ 
    ( EXCLUDE='-common -data -debug -doc -docs -el -examples -fonts -javadoc -static -tests -theme';
    for ARG in "$@";
    do
        sudo yum -y search "${ARG%%[!-A-Za-z0-9]*}" | grep --color=auto --color=auto --color=auto --color=auto -i "$ARG[^ ]* : ";
    done | sed -n "/^[^ ]/ s,\..* : , : ,p" | grep --color=auto --color=auto --color=auto --color=auto -vE "($(IFS='| '; set -- $EXCLUDE; echo "$*"))" | uniq )
}
