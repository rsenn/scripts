#!/bin/bash
MYDIR=`dirname "$0"` 
MYNAME=`basename "$0" .sh`
MYCMD=${MYNAME#git-}
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
#    git branch -a | sed -n 's,^\* ,,p' 
    git branch -a | ${SED-sed} -n 's,^\* ,,p'
}
exec_bin()
{

  while :; do
        case "$1" in
          -f | --force) FORCE="true"; shift ;;
          *) break ;;
        esac
  done

  ([ "$FORCE" = true ] && set +e
  IFS=" $IFS"; CMD="$*"
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
    #ERR=" OK" 
    ERR=
  else
    ERR=" ERROR ($R)"
  fi
  [ "$R" != 0 ] &&  { O=${O//"$NL$NL"/"$NL"}; O=$(echo "$O"|sed '/^\s*$/d'|tail -n1); : log_msg -n "$O"; } #|| O=
    [ "$VERBOSE" = true ] &&  echo "${ERR:+$ERR}${O:+: $O}" 1>&10
    
  [ "$FORCE" = true -a "$R" != 0 ] && R=0
  exit $R)
  return $?
}
log_msg() {
 (PAD="$NL"
   while :; do
	case "$1" in
	  -n | --nopad) PAD=""; shift ;;
	  *) break ;;
	esac
  done

	CMD="(IFS=\"\$NL$PAD\"; set -- \$*; echo \"${PAD}\${*"${MAXLINES:+:"1:$MAXLINES"}"}${PAD}\" 1>&10)"
	#[ "$DEBUG" = true ] && echo "+ $CMD" 1>&10
	eval "$CMD")
}


git_cmd() {

  usage() {
    echo "Usage: $(basename "$0") [OPTIONS] <DIRS...>
  -v, --verbose
  -R, --remote  
" 1>&2
  }
  exec 10>&2
  IFS="
"
  NEST=$(( ${NEST:-0} + 1 ))
  while :; do
        case "$1" in
          -h | --help) usage; exit 1 ;;
                    -x | --debug) DEBUG="true"; shift ;;
          -v | --verbose) VERBOSE="true"; shift ;;
          -R | --remote) REMOTE=$2; shift 2 ;;       -R=* | --remote=*) REMOTE=${1#*=}; shift ;;
          -C | --no*commit*) NO_COMMIT="true"; shift ;;
          -c | --command | --cmd) CUSTOM_CMD="$2"; shift 2 ;;
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

        DIR=${DIR%%/.git*}
	log_msg -n "($NEST) Entering directory $DIR ..."
	
	(set -e
	cd "$DIR" >/dev/null
	#pwd 1>&2
	REMOTES=$(git_get_remote .|awkp)
	[ -n "$CUSTOM_CMD" ] && { IFS="$IFS "; MAXLINES=5 exec_bin -f ${CUSTOM_CMD}; }
	[ "$NO_COMMIT" != true ] && { IFS="$IFS "; MAXLINES=5 exec_bin -f git commit -m ... -a; }
	case "$MYCMD" in
	  pull|push) set -- "$R"  $(git_get_branch) ;;
	  commit) set -- -m ... -a ;;
	  fetch) set -- --all --tags ;;
	esac
	for R in ${REMOTE:-$REMOTES}; do
	 exec_bin git $MYCMD "$@"
#	exec_bin  git push "$R" $(git_get_branch)
	done
	) >/dev/null
	log_msg -n "($NEST) Leaving directory $DIR ..."



  done
}

git_cmd "$@"
