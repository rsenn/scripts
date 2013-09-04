extract-slackpkg()
{ 
    : ${DESTDIR=unpack};
    mkdir -p "$DESTDIR";
    l=$(grep "$1" pkgs.files );
    pkgs=$(cut -d: -f1 <<<"$l" |sort -fu);
    files=$(cut -d: -f2 <<<"$l" |sort -fu);
    for pkg in $pkgs;
    do
        ( e=$(grep-e-expr $files);
        test -n "$files" && ( set -x;
        tar -C "$DESTDIR" -xvf "$pkg" $files 2> /dev/null ) );
    done
}
