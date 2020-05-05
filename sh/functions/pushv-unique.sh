pushv-unique() {
  local __VAR=$1 __ARG IFS=${IFS%${IFS#?}}
  shift
  for __ARG; do
    eval "! isin \$__ARG \${$__VAR}" && pushv "$__VAR" "$__ARG" || return 1
  done
}
