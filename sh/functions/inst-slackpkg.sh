inst-slackpkg()
{
  NL="
"
    ( . require.sh;
    require array;
    while :; do
        case "$1" in
            -a)
                ALL=true;
                shift
            ;;
            -f)
                FILE=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    INSTALLED=;
    EXPR="$(grep-e-expr "$@")";
    [ "$FILE" = true ] && EXPR="/$EXPR[^/]*\$";
    PKGS=` ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -H -E "$EXPR" $([ "$PWD" = "$HOME" ] && ls -d slackpkg*)  ~/slackpkg* | ${SED-sed} 's,.*:/,/, ; s,/slackpkg[^./]*\.list:,/,'`;
    if [ -z "$PKGS" ]; then
        echo "No such package $EXPR" 1>&2;
        exit 2;
    fi;
    set -- $PKGS;
    IFS="
$IFS";
    if [ "$ALL" != true -a $# -gt 1 ]; then
        echo "Multiple packages:" 1>&2;
        echo "$*" 1>&2;
        exit 2;
    fi;
    for PKG in "$@";
    do
        NAME=${PKG##*/};
        NAME=${NAME%.t?z};
        if ! array_isin INSTALLED "$NAME"; then
            echo "Installing $PKG ..." 1>&2;
            ( echo;
            installpkg "$PKG" 2>&1;
            echo ) >> install.log;
            array_push_unique INSTALLED "$NAME";
        else
            echo "Package $PKG already installed" 1>&2;
        fi;
    done )
}
