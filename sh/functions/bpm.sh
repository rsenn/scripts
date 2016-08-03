bpm() {
  id3v2  -l "$@"|${SED-sed} -n "/^id3v2 tag info for / {
    :lp
    N
    /\n[[:upper:][:digit:]]\+ ([^\n]*$/ {
      /\nTBPM[^\n]*$/! {
        s|\n[^\n]*$||
        b lp
      }
      s|TBPM (.*): ||g
      b ok
    }
    /:\s*$/! {
      s|\n| |g
      b lp
    }
    :ok
    s|\n[^\n]*:\s*$||
    s|^id3v2 tag info for \([^\n]*\) *: *\n *|\1: |
    p
  }"
}
