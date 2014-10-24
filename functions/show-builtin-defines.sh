show-builtin-defines() {
 (NARG=$#
  CMD='"$ARG" -dM -E - <<<""'
  if [ "$NARG" -gt 1 ]; then
    CMD="$CMD <<EOF | addprefix \"\$ARG\":"
  fi
  eval "for ARG; do
    $CMD
EOF
  done")
}
