add-cond-include() {
 (INC="$1"
  shift

  INCNAME="${INC##*/include/}"
  INCDEF=HAVE_$(echo "$INCNAME" | sed 's,[/.],_,g' | tr '[[:'{lower,upper}':]]') 

  sed -i "\\|^\s*#\s*include\s\+[<\"]\s*$INCNAME[>\"]| {
    s|.*|#ifdef $INCDEF\n&\n#endif /* defined $INCDEF */|
  }" "$@"

  )
}
