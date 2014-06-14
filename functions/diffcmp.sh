diffcmp()
{
    diff "$@" |
    sed -n \
      -e 's/^Binary files \(.*\) and \(.*\) differ/\1\n\2/p' \
      -e 's,^[-+][-+][-+]\s\+\([^ \t]\+\)\s.*,\1,p' \
    | uniq
}
