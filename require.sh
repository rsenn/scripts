# require.sh: load external shell script libraries
#
# This file is part of the libswsh package, the software shell library.
# It provides integration of the "require" command into a bash shell
# configuration.

: ${prefix:="/usr"}
: ${exec_prefix:="/usr"}
: ${libdir:="${exec_prefix}/lib"}
: ${shlibdir:="${libdir}/sh"}

# require <library1> [library2...]
# ---------------------------------------------------------------------------
require()
{
  local mask script retcode cmd="source" pre=""

  while :; do
    case $1 in
      -p) cmd="echo" ;;
      -n) pre="$shlibdir/" ;;
      *) break ;;
    esac
    shift
  done

  script=${1%.sh}

  for mask in \
    $shlibdir/$script.sh \
    $shlibdir/*/${script%.sh}.sh \
    $shlibdir/*/*/${script%.sh}.sh
  do
    if test -r "$mask"; then
      if test "$cmd" = echo && test -n "$pre"; then
        mask=${mask#$pre}
      fi
      $cmd "$mask"
      return 0
     fi
  done
  echo "ERROR: loading shell script library $shlibdir/$script.sh" 1>&2
  return 127
}

# importlibs
# ---------------------------------------------------------------------------
importlibs()
{
  local lib IFS="|"

  for lib in $__LIBS__
  do
    if ! source $shlibdir/$lib.sh 2>/dev/null
    then
      echo "Error loading $lib.sh" 1>&2
      return $?
    fi
  done
}


# ---------------------------------------------------------------------------
if test -n "$PS1" -a -n "$BASH"
then
  importlibs
fi

# _shlibs
# ---------------------------------------------------------------------------
_shlibs()
{
  local oldifs="$IFS" file libs IFS=/ cur=${COMP_WORDS[COMP_CWORD]} i=0

#  set -- $cur

  IFS="
$oldifs "

  while :
  do
    local libs=$(
      cd "$shlibdir" &&
      ls -d "$cur"*.sh "$cur"*/ 2>/dev/null
    )

    if test -n "$cur" && test "$cur" = "${cur%/*}"
    then
      libs=$libs'
'`cd "$shlibdir" && find */ -name "*.sh" | sed 's,.*/,,'`
    fi

    COMPREPLY=( $( compgen -W "`echo "$libs" | sed 's,\.sh$,,'`" -- $cur ) )

    if [ ${#COMPREPLY[@]} = 1 ]
    then
      case ${COMPREPLY[0]} in
        */) cur="${COMPREPLY[0]}" && continue ;;
      esac

      if ! test -f "$shlibdir/${COMPREPLY[0]}.sh"
      then
        COMPREPLY=( `cd "$shlibdir" && find */ -name "${COMPREPLY[0]}.sh" | sed 's,\.sh$,,'` )
      fi
    fi

    break
  done

  return 0
}

# Activate the completion
# ---------------------------------------------------------------------------
complete -F _shlibs require reload

# End of require.sh
