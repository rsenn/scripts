pkginst()
{ 
    ( PKGS=`pkgsearch "$@"`;
    set -- ${PKGS%%" "*};
    if [ $# -gt 0 ]; then
        sudo yum -y install "$@";
    fi )
}
