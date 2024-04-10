pkg-joinlines() {
sed '\|^[^\s]| { N; N; s,\n, ,g ; s,^\([^\s/]*\)/\([^\s]\+\),\1, }' | sed 's,/[^ \t]*\s, ,'
}
