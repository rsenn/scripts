list-upx()
{
    upx -l "$@" 2>&1 | ${SED-sed} '1 { :lp; N; /^\s*--\+/! b lp; d; }' | ${SED-sed} '$ { /[0-9]\sfiles\s\]$/d; } ; /^\s*[- ]\+$/d'
}
