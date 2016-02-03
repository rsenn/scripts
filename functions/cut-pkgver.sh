cut-pkgver()
{
    cat "$@" |${SED-sed} 's,-[0-9]\+$,,g'
}
