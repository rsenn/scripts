prof()
{
    PROF="$HOME/.bash_profile";
    case "$1" in
        load* | source* | relo*)
            . "$PROF"
        ;;
        edit)
            "${2:-$EDITOR}" "$(cygpath -m "$PROF")"
        ;;
    esac
}
