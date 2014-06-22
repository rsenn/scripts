escape_required()
{
    local b="\\" q="\`\$\'\"${IFS}";
    case "$1" in
        '')
            return 1
        ;;
        ["$q"]* | *[!"$b"]["$q"]*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}
