parent-file() {
 (recurse() {
    FN=${1##*/}
    DIR=${1%/*}
    while ! [ "$DIR" -ef "$DIR/.." ]
    do
     PARENT=$(cd "$DIR/.." && pwd)
        [ -e "$PARENT/$FN" ] && DIR=$PARENT || break
      echo "PWD: ${PWD}" 1>&2
   done
    if [ -e "$DIR/$FN" ]; then
      return 0
    fi
    return 1
  }

  while [ $# -gt 0 ]; do
     recurse "$1"
     echo "$DIR/$FN"
     shift
  done)
}
