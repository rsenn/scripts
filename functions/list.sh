list()
{
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}
list()
{
    sed "s|/files\.list:|/|"
}
list()
{
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}
list()
{
    sed "s|/files\.list:|/|"
}
list()
{
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}
list()
{
    sed "s|/files\.list:|/|"
}
list()
{
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}
list()
{
 (IFS="
 "
  : ${INDENT='  '}
  while :; do
    case "$1" in
      -i) INDENT=$2 && shift 2 ;;
      -i*) INDENT=${2#-i} && shift
      ;;
      *) break ;;
    esac
  done

  CMD='echo -n " \\
$INDENT$LINE"'
  [ $# -ge 1 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}
list() {
  rpm-cmd -t -- "$@"
}
list()
{
 (IFS="
 "
  : ${INDENT='  '}
  while :; do
    case "$1" in
      -i) INDENT=$2 && shift 2 ;;
      -i*) INDENT=${2#-i} && shift
      ;;
      *) break ;;
    esac
  done

  CMD='echo -n " \\
$INDENT$LINE"'
  [ $# -ge 1 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}
list() {
  rpm-cmd -t -- "$@"
}
list()
{
 (IFS="
 "
  : ${INDENT='  '}
  while :; do
    case "$1" in
      -i) INDENT=$2 && shift 2 ;;
      -i*) INDENT=${2#-i} && shift
      ;;
      *) break ;;
    esac
  done

  CMD='echo -n " \\
$INDENT$LINE"'
  [ $# -ge 1 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}
list() {
  rpm-cmd -t -- "$@"
}
