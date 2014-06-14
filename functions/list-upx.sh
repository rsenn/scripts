list-upx()
{
    upx -l "$@" 2>&1 | sed '1 { :lp; N; /^\s*--\+/! b lp; d; }' | sed '$ { /[0-9]\sfiles\s\]$/d; } ; /^\s*[- ]\+$/d'
}
