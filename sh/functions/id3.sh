id3()
{
    $ID3V2 -l "$@" | ${SED-sed} "
  s,^\([^ ]\+\) ([^:]*):\s\?\(.*\),\1=\2,
   s,.* info for s\?,,
  /:$/! { /^[0-9A-Z]\+=/! { s/ *\([^ ]\+\) *: */\n\1=/g; s,\s*\n\s*,\n,g; s,^\n,,; s,\n$,,; s,\n\n,,g; }; }" | ${SED-sed} "/:$/ { p; n; :lp; N; /:\$/! { s,\n, ,g;  b lp; }; P }"
}
