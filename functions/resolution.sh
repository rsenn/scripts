resolution()
{
 (minfo "$@"|sed -n "/Width: / { N; /Height:/ { s,Width:,, ; s,[^:\n0-9]\+: \+\([^:]*\)\$,\1,g; s,\n[^\n]*:,x,g; p } }")
}
