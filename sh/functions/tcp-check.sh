tcp-check() {
        (TIMEOUT=10
        for ARG; do
        HOST=${ARG%:*}
        PORT=${ARG#$HOST:}

        if type tcping 2>/dev/null >/dev/null; then
          CMD='tcping -q -t "$TIMEOUT" "$HOST" "$PORT"; echo "$?"'
        else
          CMD='echo -n |(nc -w 10 "$HOST" "$PORT" 2>/dev/null >/dev/null;  echo "$?")'
        fi

        RET=`eval "$CMD"`

        if [ "$RET" -eq 0 ]; then
          echo "$HOST:$PORT"
        fi

        if [ $# -le 1 ]; then
          exit "$RET"
        fi
      done)
}
