cpan-install()
{ 
    for ARG in "$@";
    do
        perl -MCPAN -e "CPAN::Shell->notest('install', '$ARG')";
    done
}
