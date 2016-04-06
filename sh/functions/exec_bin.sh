exec_bin()
{
  (IFS=" $IFS"; CMD="$*"
  [ "$DEBUG" = true ] &&  echo "+ $CMD" 1>&2 
  exec "$@")
}

