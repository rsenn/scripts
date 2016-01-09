show-builtin-defines() {
 (NARG=$#
  CMD='"$ARG" -dM -E - <<EOF
EOF'
  if [ "$NARG" -gt 1 ]; then
    CMD="$CMD | addprefix \"\$ARG\":"
  fi
  eval "for ARG; do
    $CMD
  done")
}
