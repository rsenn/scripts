remove-cond-include() {
 (INC="$1"
  shift

  INCNAME="${INC##*/include/}"
  INCDEF=HAVE_$(echo "$INCNAME" | ${SED-sed} 's,[/.],_,g' | tr '[[:'{lower,upper}':]]')

  ${SED-sed} -i "\\|^\s*#\s*if[^\n]*def[^\n]*$INCDEF| {
    :lp
    /#\s*endif/! { N; b lp; }

   s|^\s*#\s*if[^\n]*def[^\n]*$INCDEF[^\n]*\n||
   s|[^\n]*#[^\n]*endif[^\n]*$||
  }" "$@"

  )
}
