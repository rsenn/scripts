cut-pkgver()
{
    cat "$@" |sed 's,-[0-9]\+$,,g'
}
