extract_version()
{ 
    echo "$*" | sed 's,^.*\([0-9]\+[-_.][0-9]\+[-_.0-9]\+\).*,\1,'
}
