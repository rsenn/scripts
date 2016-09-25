du-txt() {
 (IFS="
"; TMP="du.tmp$RANDOM"
  while :; do
    case "$1" in
      -x | --debug) DEBUG=true; shift ;;
      -0 | --null | -a | --all | --apparent-size | -c | --total | -D | --dereference-args | --summarize | -H | --dereference-args | -h | --human-readable | --inodes | -L | --dereference | -l | --count-links | -P | --no-dereference | -S | --separate-dirs | --si | -h | -s | --summarize | --time | -x | --one-file-system | --help | --version | --block-size) pushv DU_ARGS "$1"; shift ;;
      -B=* | -b=* | -d=* | -k=* | -m=* | -t=* | -X=*) pushv DU_ARGS "${1%%=*}" "${1#-?=}"; shift ;;
      -B | -b | -d | -k | -m | -t | -X) pushv DU_ARGS "$1" "$2"; shift 2 ;;
      -B* | -b* | -d* | -k* | -m* | -t* | -X*) A=${1#-?}; pushv DU_ARGS "${1%%$A}" "${A}"; shift ;;
      --block-size=* | --exclude-from=* | --exclude=* | --files0-from=* | --max-depth=* | --threshold=* | --time-style=* | --time=*) pushv DU_ARGS "$1"; shift ;;
      --block-size | --exclude | --exclude-from | --files0-from | --max-depth | --threshold | --time | --time-style) pushv DU_ARGS "$1=$2"; shift 2 ;;
      *) break ;;
    esac
  done
  echo -n > "$TMP"
  trap 'rm -f "$TMP"' EXIT
  CMD='(du -x -s $DU_ARGS -- ${@-$(ls-dirs)})'
  if [ -w "$TMP" ]; then
      CMD="$CMD | (tee \"\$TMP\"; sort -n -k1 <\"\$TMP\" >du.txt; rm -f \"\$TMP\"; echo \"Saved list into du.txt\" 1>&2)"
  fi
  [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
  eval "$CMD")
}
