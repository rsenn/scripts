port-joinlines() { 
  ${SED-sed} -n '/ @/ {
    :lp
    /\n *$/! { N; b lp; }
    s|\n| - |g
    s|[- ]*$||; p
  }'
}
