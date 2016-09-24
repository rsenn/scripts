reg-export()
{
 (OUT=$(mktemp tmp-XXXXXX.txt);
  trap 'rm -f "$OUT"' EXIT;
  reg export "$1" "$OUT" -y >/dev/null || exit $?
  CMD='iconv -f UTF-16 -t UTF-8 <"$OUT"'
  [ "$2" ] && CMD="$CMD | sed -n '1p; 2p; /\[.*\]/ {
    p
    :lp1
    n
    \|^\"\?$2\"\?=|! b lp1
    :lp2
    N
    /\\\\\\s*$/ b lp2

    s|\\s*\\\\\\n\\s*||g

    p
    q
  }'"
      eval "$CMD"
  )
}
