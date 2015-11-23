#!/bin/bash
MYDIR=`dirname "$0"` 

git_get_remote () 
{ 
    ( while :; do
        case "$1" in 
            -l | --list)
                LIST=true;
                shift
            ;;
            -n | --name)
                NAME=$2;
                shift 2
            ;;
            -n=* | --name=*)
                NAME=${1#*=};
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# -lt 1 ] && set -- .;
    [ $# -gt 1 ] && FILTER="${SED-sed} \"s|^|\$DIR: |\"" || FILTER=;
    EXPR="s|\\s\\+| |g";
    if [ -n "$NAME" ]; then
        EXPR="$EXPR ;; \\|^$NAME\s|!d";
    fi;
    if [ "$LIST" = true ]; then
        EXPR="$EXPR ;; s| .*||";
    else
        EXPR="$EXPR ;; s|\\s*([^)]*)||";
    fi;
    CMD="REMOTE=\`git remote -v 2>/dev/null";
    CMD="$CMD | ${SED-sed} \"$EXPR\"";
    CMD="$CMD |uniq ${FILTER:+|$FILTER}\`;";
    CMD=$CMD'echo "$REMOTE"';
    for DIR in "$@";
    do
        ( cd "${DIR%/.git}" > /dev/null && eval "$CMD" );
    done )
}
removesuffix () 
{ 
    ( SUFFIX=$1;
    shift;
    CMD='echo "${LINE%$SUFFIX}"';
    if [ $# -gt 0 ]; then
        CMD="for LINE; do $CMD; done";
    else
        CMD="while read -r LINE; do $CMD; done";
    fi;
    eval "$CMD" )
}

awkp () 
{ 
    ( IFS="
	";
    N=${1};
    set -- awk;
    case $1 in 
        -[A-Za-z]*)
            set -- "$@" "$1";
            shift
        ;;
    esac;
    "$@" "{ print \$${N:-1} }" )
}
git_get_remote () 
{ 
    ( while :; do
        case "$1" in 
            -l | --list)
                LIST=true;
                shift
            ;;
            -n | --name)
                NAME=$2;
                shift 2
            ;;
            -n=* | --name=*)
                NAME=${1#*=};
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# -lt 1 ] && set -- .;
    [ $# -gt 1 ] && FILTER="${SED-sed} \"s|^|\$DIR: |\"" || FILTER=;
    EXPR="s|\\s\\+| |g";
    if [ -n "$NAME" ]; then
        EXPR="$EXPR ;; \\|^$NAME\s|!d";
    fi;
    if [ "$LIST" = true ]; then
        EXPR="$EXPR ;; s| .*||";
    else
        EXPR="$EXPR ;; s|\\s*([^)]*)||";
    fi;
    CMD="REMOTE=\`git remote -v 2>/dev/null";
    CMD="$CMD | ${SED-sed} \"$EXPR\"";
    CMD="$CMD |uniq ${FILTER:+|$FILTER}\`;";
    CMD=$CMD'echo "$REMOTE"';
    for DIR in "$@";
    do
        ( cd "${DIR%/.git}" > /dev/null && eval "$CMD" );
    done )
}
git_get_branch () 
{ 
    git branch -a | ${SED-sed} -n 's,^\* ,,p'
}

if [ $# -gt 0 ]; then
  set -- $(find "$@"  -type d -name ".git"|removesuffix /.git)
else
  set -- $(git_get_remote "$MYDIR"/*/|grep -E ' (/var/lib/git|github\.com/|ssh://.*crowdguard.org)'|cut -d: -f1|removesuffix / )
fi

for DIR ; do 


  echo "
Entering directory $DIR ...
" 1>&2
  
  (
  cd "$DIR"
  REMOTES=$(git_get_remote .|awkp)
    git commit -m ... -a
  for R in $REMOTES; do
    git pull "$R" $(git_get_branch)
    git push "$R" $(git_get_branch)
  done
  ) >/dev/null
  echo "
Leaving directory $DIR ...
" 1>&2
  echo 1>&2



done
