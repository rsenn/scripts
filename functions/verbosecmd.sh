verbosecmd() {
  CMD='"$@"'
  while :; do
    case "$1" in
      -2=1 | -err=out | -stderr=stdout) CMD="$CMD 2>&1"; shift ;;
      -1=* | -out=* | -stdout=*) CMD="$CMD 1>${1#*=}"; shift ;;
      -1+=* | -out+=* | -stdout+=*) CMD="$CMD 1>>${1#*=}"; shift ;;
      *) break ;;
    esac
  done
  echo "+ $@" 1>&2
  eval "$CMD; return \$?"
}