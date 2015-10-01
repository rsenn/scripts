make-sizes-tmp() 
{ 
    sed -n '/ [0-9]\+ /p' $(list-mediapath 'ls-lR.list') | awkp 5 > $TEMP/sizes.tmp;
    for N in $(histogram.awk <$TEMP/sizes.tmp|grep -v '^1 '|awkp 2|sort -n); do
      test "$N" -le 0 && continue
      echo "/^[^ ]\+\s\+[0-9]\+\s\+[0-9]\+\s\+[0-9]\+\s\+$N /p"
      done |(set -x; tee $TEMP/sizes.sed >/dev/null)
}
