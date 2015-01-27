resolution()
{  
  (minfo "$@"|sed -n "/Width\s*: / { N; /Height\s*:/ { s,Width\s*:,, ; s,[^:\n0-9]\+: \+\([^:]*\)\$,\1,g; s|^\s*||; s|\([0-9]\)\s\+\([0-9]\)|\1\2|g; s|\s*pixels||g;  s|\n|x|g; p } }")
}
