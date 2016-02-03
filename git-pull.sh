#!/bin/bash
MYDIR=`dirname "$0"` 
NL="
"

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
    [ $# -gt 1 ] && FILTER="sed \"s|^|\$DIR: |\"" || FILTER=;
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
    CMD="$CMD | sed \"$EXPR\"";
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
    [ $# -gt 1 ] && FILTER="sed \"s|^|\$DIR: |\"" || FILTER=;
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
    CMD="$CMD | sed \"$EXPR\"";
    CMD="$CMD |uniq ${FILTER:+|$FILTER}\`;";
    CMD=$CMD'echo "$REMOTE"';
    for DIR in "$@";
    do
        ( cd "${DIR%/.git}" > /dev/null && eval "$CMD" );
    done )
}
git_get_branch () 
{ 
    git branch -a | sed -n 's,^\* ,,p'
} 
exec_bin()
{
  (IFS=" $IFS"; CMD="$*"
  exec 10>&2
  [ "$VERBOSE" = true ] &&  echo -n "+ $CMD" 1>&10
  TMP="msg$$.tmp"
  trap 'rm -f "$TMP"' EXIT
  exec >"$TMP"
  if [ "$DEBUG" = true ]; then
  :
  else 
:
  fi
  
  "$@" 2>&1
  
  R=$?
  O=$(<"$TMP")
  rm -f "$TMP"; trap '' EXIT
  if [ "$R" = 0 ] ; then
    ERR=" OK" 
  else
    ERR=" (ERROR: $R)"
  fi
    [ "$VERBOSE" = true ] &&  echo "${ERR:+$ERR}" 1>&10
    
  [ "$R" != 0 ] &&    log_msg "$O")
  
}
log_msg() {
	echo "${NL}$*${NL}" 1>&2
}


main() {
  while :; do
        case "$1" in
          -x | --debug) DEBUG="true"; shift ;;
          -v | --verbose) VERBOSE="true"; shift ;;
          -p | --print) EVALCMD="echo"; shift ;;
          *) break ;;
        esac
  done


  if ! [ $# -gt 0 ]; then
	set -- $(git_get_remote "$MYDIR"/*/|grep -E ' (/var/lib/git|github\.com/|ssh://.*crowdguard.org)'|cut -d: -f1|removesuffix / )
#  else
#	set -- $(find "$@"  -type d -name ".git"|removesuffix /.git)
  fi
  [ "$DEBUG" = true ] && echo "$# Arguments" 1>&2
  for DIR ; do 


	log_msg "Entering directory $DIR ..."
	
	(
	cd "$DIR"
	REMOTES=$(git_get_remote .|awkp)
	 exec_bin git commit -m ... -a
	for R in $REMOTES; do
	 exec_bin git pull "$R" $(git_get_branch)
	exec_bin  git push "$R" $(git_get_branch)
	done
	) >/dev/null
	log_msg "Leaving directory $DIR ..."



  done
}

main "$@"