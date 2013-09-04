#!/bin/sh

#set -e

case `type echo`:`echo -e ...` in
  *builtin*:-e*) echo_e_arg= ;;
  *) echo_e_arg="-e" ;;
esac

# Be more Bourne compatible - stolen from GNU autoconf
# ---------------------------------------------------------------------------
DUALCASE=1; export DUALCASE # for MKS sh
if test -n "${ZSH_VERSION+set}" && (emulate sh) >/dev/null 2>&1; then
  emulate sh
  NULLCMD=:
  # Zsh 3.x and 4.x performs word splitting on ${1+"$@"}, which
  # is contrary to our usage.  Disable this feature.
  alias -g '${1+"$@"}'='"$@"'
  setopt NO_GLOB_SUBST
else
  case `(set -o) 2>/dev/null` in
    *posix*) set -o posix ;;
  esac
fi

# setup_cache [name=value] [name] 
#
# caches configuration values and reads them back. 
# no arguments will clear the cache.
# ---------------------------------------------------------------------------
setup_cache()
{
  while :; do
    case $1 in
      *=*)
        if [ "${1%%=*}" != SED ]; then
          if test -f setup.cache; then
            $SED -i -e "/^${1%%=*}=/d" setup.cache
          fi
          echo "$1" >>setup.cache
        fi
      ;;
    esac
    shift
  done
}

# setup_program <variable-name> <program-name>
#
# sets the specified variable to the program name.
# ---------------------------------------------------------------------------
setup_program()
{
  path="no" IFS=: fail=127
  
  while :; do
    case $1 in
      -p) path=yes ;;
      -i) fail=0 ;;
      *) break ;;
    esac
    shift
  done
 
  var=$1 && shift
  eval "value=\"\${$var}\""
  
  if [ -z "$value" ]; then
    for cmd; do
      ${quiet+true} echo ${echo_e_arg} "checking for $var ($cmd)... \c" 1>&2
      try=${cmd%%' '*}
      IFS=:
      for dir in $PATH; do
        IFS=" ""
";      
        if [ -x "$dir/$try" ]; then
          if test "$path" = yes; then
	          value="$dir/$cmd"
          else
            value="$cmd"
          fi
	        ${quiet+true} echo "$value" 1>&2
          eval "$var=\"\$value\""
#          setup_cache "$var=$value"
          return 0
        fi
      done
      echo "!fail!" 1>&2
    done
    return $fail
  fi
  return 0
}

# setup_spawn <command> [arguments...]
#
# prints the command line of the program to execute and then executes it.
# ---------------------------------------------------------------------------
setup_spawn()
{
  out= cond="true"
  while :; do
    case $1 in
      -o) out=$2 && shift ;;
      -c) cond=$2 && shift ;;
      *) break ;;
    esac
    shift
  done
  eval "$cond" || return 0

 (${quiet+true} echo "$@${out:+ >|$out}" 1>&2
#  eval "\${@}${out:+ >$out}")
  IFS=" "
  eval "$*${out:+ >|$out}")

}

# setup_init <arguments...>
#
# initialization routine. Detects some require utilities. 
# upon completion it will set the following variables:
#
#  $CC            C compiler
#  $SED           stream editor
#  $TOUCH         file timestamp updater
#  $INSTALL_DATA  installation utility
#  $LN            hard/soft-link utility
#  $NEWFILE       the "newfile" utility
#
# ---------------------------------------------------------------------------
setup_init()
{
#  setup_bash "$@"

  # parse arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --*=*) 
        export "${1#--}" 
      ;;

      *=*) 
        export "$1" 
      ;;

      --*)
        export "${1#--}="
#        test "${2+set}" = set && shift 
      ;;

      *)
        if test -z "$setup_cmd"; then
          setup_cmd="$1"
        else
          setup_args="${setup_args:+$setup_args }$1"
        fi
      ;;
    esac
    shift
  done
  
  # no command?
  if test -z "$setup_cmd"; then
    setup_cmd="build"
#    setup_usage 1 "no command supplied"
  fi

  # utilities required to build this package
  setup_program SED sed
  setup_program RM rm
  
  # Check for available shells
  setup_shells=

  setup_program SHELL "bash" "ash" "ksh" "zsh" "sh"
  test -z "$BASH" && setup_program BASH "bash" && setup_shells="${setup_shells+$setup_shells }bash"
  setup_program DASH "dash" && setup_shells="${setup_shells+$setup_shells }dash"
  setup_program ASH "ash" && setup_shells="${setup_shells+$setup_shells }ash"
  setup_program SH "sh" && setup_shells="${setup_shells+$setup_shells }sh"

  # the compiler can help to detect the target system type
  setup_program -i CC "gcc"

  # utilities required to install this package
  setup_program INSTALL_DATA "install -m 644" "cp"
  setup_program INSTALL_EXEC "install -m 755" "cp"
  setup_program INSTALL_DIR "install -d" "mkdir -p"
  setup_program LN "ln"
  
  # required to develop on libswsh:
  setup_program -i DEVTODO "devtodo"
  
  # third-party software supported and extended by libswsh:
  setup_program -p -i NEWFILE "newfile"

  setup_program CURL curl
}

# setup_toolchain
#
# host system and installation prefix detection. Expects $CC to be a valid 
# c compiler.
#
# on completion it will set the variables $host (system-triplet) and $prefix 
# ---------------------------------------------------------------------------
setup_toolchain()
{
  if test -z "$host" -o -z "$prefix"; then
    host=`${CC:-true} -dumpmachine 2>/dev/null`

    if test -z "$host"; then
      host=`./build/gnu/config.guess 2>/dev/null || true`
      prefix="/usr"
    else
      prefix=$(
        ${CC:-true} -print-search-dirs 2>/dev/null |
        ${SED} -n '/^install:/ s|^install: \([^ ]\+\)/lib/.*|\1| p'
      )
    fi
  fi

  # default prefix
  if [ -z "$prefix" ]; then
    prefix="/usr"
  fi
}

# setup_subst <name[=value]...>
#
# adds a substitution expression which will replace every occurence of
# "@$name@" with "$value". Expressions are added to the global transform
# script in $setup_expr, which can be u${SED} for transforming files using ${SED}.
# ---------------------------------------------------------------------------
setup_subst()
{
  for arg; do
    name="${arg%%[!_0-9A-Za-z]*}"
    arg="${arg#$name}"
    
    case $arg in
      =*) value="${arg#=}" ;;
      *) eval "value=\${$name$arg}" ;;
    esac

    setup_expr="${setup_expr+$setup_expr;;}s|@$name@|$value|g"
  done
}

# setup_dirs
# 
# expects: 
#   $host, $prefix
#
# outputs eventually:
#   $sysconfdir, $localstatedir, $bindir, $sbindir (eventually)
# ---------------------------------------------------------------------------
setup_dirs()
{
  case $prefix in
    "/usr" | "/")
      sysconfdir="/etc"
      localstatedir="/var"
    ;;
  esac

  case $prefix in
    "/")
      bindir="/bin"
      sbindir="/sbin"
    ;;
  esac
  
  # provide installation directory substitutions
  setup_subst \
    'prefix' \
    'exec_prefix-\$prefix' \
    'sysconfdir-\$prefix/etc' \
    'localstatedir-\$prefix/var' \
    'bindir-\$prefix/bin' \
    'libdir-\$prefix/lib' \
    'shlibdir-\$libdir/sh' \
    'datadir-\$prefix/share' \
    'docdir-\$prefix/share/doc' \
    'templatedir-\$pkgdatadir/templates' \
    
  # provide data directory substitutions
  setup_subst \
    'pkgdatadir-\$datadir/libswsh' \
    'portsdir-\$prefix/ports' \
    'pkgdir-\$prefix/pkg' \
    'pkgdocdir-\$docdir/libswsh'

  setup_subst CURL
}

# setup_config
#
# sets up the build configuration. It provides substitution for target system
# dependencies and for build modes
# ---------------------------------------------------------------------------
setup_config()
{
  # tools and other dependencies:
  setup_subst 'SHELL-/bin/sh'

  # debug mode substitutions:
  # 
  #  @DEBUG_TRUE@   U${SED} in front of lines which are enabled in debug 
  #                 builds only.
  # 
  #  @DEBUG_FALSE@  For lines which should be enabled in release builds only.
  #
  setup_subst 'DEBUG_TRUE-#' 'DEBUG_FALSE'
}

# setup_build <directory> [patterns...]
#
# transforms files according to the substitution script in $setup_expr
# ---------------------------------------------------------------------------
setup_build()
{
  dir="$1"
  shift
  setup_recurse "$dir" | setup_list | while read file; do
    ifs=$IFS IFS="|$IFS"; eval "IFS=\$ifs; case \$file in
      Makefile.in) continue ;;
      ${*:-*.in}) ;;
      *) continue ;;
    esac"
    if test "${force+set}" != set; then
      test ! "${file}" -nt "${file%.in}" && continue
    fi
    ${quiet+true} echo "$SED -e ... $file >${file%.in}" 1>&2
    $SED -e "$setup_expr" $file >${file%.in}
  done
}

# setup_clean <directory>
# ---------------------------------------------------------------------------
setup_clean()
{
  setup_recurse "$@" | setup_list | while read file; do
    if [ -e "$file.in" ]; then
      setup_spawn $RM -f "$file"
    fi
  done  
}

# setup_recurse <dirs...>
# ---------------------------------------------------------------------------
setup_recurse()
{
 (for dir; do
    test -d "$dir" || continue
    set --
    for dent in $dir/*; do
      name=${dent##*/}
      case $name in
        .*) continue ;;
      esac
      if [ -d "$dent" ]; then
        set -- "$@" "$dent"
      elif [ -e "$dent" ]; then
        dir="${dir:+$dir }${name}"
      fi
    done
    echo "$dir"
    setup_recurse "$@"
  done)
}

# setup_list 
#
# reads output from setup_recurse and displays a flat list
# ---------------------------------------------------------------------------
setup_list()
{
 (while read dir files; do
    for file in $files; do
      echo "$dir/$file"
    done
  done)
}

# setup_merge <destdir> [masks]
#
# merge a source tree (filenames read from stdin) to the given destination directory
# ---------------------------------------------------------------------------
setup_merge()
{
  basedir= subdir= dstdir=$1 
  shift
  while read dir files; do
    if test -z "$basedir"; then
      basedir="$dir"
    fi
    subdir=${dir#$basedir} list=
    for file in $files; do
      ifs=$IFS IFS="|$IFS" &&
      eval "IFS=\$ifs; case \$file in
        ${*:-*.sh|*.bash|*.ash|*.zsh|*.tcsh})
          list=\"\${list:+\$list }\$file\"
          ;;
      esac" 
    done
    if test -n "$list"; then
      setup_spawn -c "test ! -d '$dstdir$subdir'" $INSTALL_DIR "$dstdir$subdir"

    (IFS=" " subdir=${subdir#/}
     set -- $list      
     echo "installing modules${subdir:+ in $subdir}: ${@%.*}" 1>&2
     cd "$dir" && $INSTALL_DATA $list "$dstdir/$subdir")
    fi
  done
}

# setup_install
# ---------------------------------------------------------------------------
setup_install()
{
  # install shell library scripts
  : ${shlibdir=${libdir=$prefix/lib}/sh}
  
  (setup_recurse "lib" | setup_merge "$shlibdir")
  (setup_recurse "src" | setup_merge "$shlibdir" "*.sh|*.bash")

  # install substitution templates

  # determine the (sys)profile.d directory
  # for modular initialization of the shell.
  for profiledir in ${sysconfdir-$prefix/etc}/{,sys}profile.d; do
    test -d "$profiledir" && break
  done

  if [ -n "$profile" ]; then
    setup_spawn -c "test ! -d '$profiledir'" $INSTALL_DIR "$profiledir"
  fi

  # install require.sh containing the require() function
  # into the shell profile directory.
  for profiledir in ${sysconfdir-$prefix/etc}/{,sys}profile.d; do
    test -d "$profiledir" || continue

    setup_spawn $LN -sf "$shlibdir/require.sh" "$profiledir"
    
    if [ -n "$_BASH_" ]; then
      setup_spawn -c "test -n '$_BASH_'" $LN -sf "require.sh" "$profiledir/require.bash"
    fi
  done

  # install the sw script into the binary directory
  setup_spawn -c "test ! -d '${bindir=$prefix/bin}'" $INSTALL_DIR "$bindir"

  setup_spawn $INSTALL_EXEC "src/sw" "$bindir"

  for script in src/*/[!A-Z]*.in; do
    setup_spawn $INSTALL_EXEC "${script%.in}" "$bindir"
  done

  # install the newfile templates
  if [ -n "$NEWFILE" ]; then

    NEWFILE_PREFIX=${NEWFILE%/bin/newfile}

    if [ -d "$NEWFILE_PREFIX" ]; then
      ${quiet+true} echo "Found newfile installation in ${NEWFILE_PREFIX}, installing templates..." 1>&2

      NEWFILE_DATADIR=${NEWFILE_PREFIX}/share/newfile

      test -d "$NEWFILE_DATADIR/templates" || $INSTALL_DIR "$NEWFILE_DATADIR/templates"

      for tmpl in data/*@*; do
        setup_spawn -o "$NEWFILE_DATADIR/templates/"`basename "$tmpl"` $SED -e "s:@prefix@:$prefix:g" "$tmpl"
#        $SED -e "s:@prefix@:$prefix:g" "$tmpl" >"$NEWFILE_DATADIR/templates/"`basename "$tmpl"`
      done
    fi
  fi  
  
  # install remaining template files
  : ${pkgdatadir="${datadir=$prefix/share}/libswsh"}
  : ${templatedir="$pkgdatadir/templates"}
  
  setup_spawn -c "test ! -d '$templatedir'" $INSTALL_DIR "$templatedir"
  setup_spawn $INSTALL_DATA data/Pkgtemplate "$templatedir"
  
  # install the documentation
  : ${docdir="$prefix/share/doc"}
  : ${pkgdocdir="$docdir/libswsh"}

  set --

  for file in COPYING README TODO AUTHORS; do
    test -f "$file" && set -- "$@" $file
  done

  setup_spawn $INSTALL_DIR "$pkgdocdir"
  setup_spawn $INSTALL_DATA "$@" "$pkgdocdir"
}

# setup_usage
# ---------------------------------------------------------------------------
setup_usage()
{
  echo "usage: ${0##*/} [command] [options...]
  
available commands:
    config               check build prerequisites
    build                build deployable shell script library
    install              install the shell script library
    clean                clean the transformed shell scripts and auxiliary files
    dist                 create a distribution tarball
  
options:
  --force                force overwriting of up-to-date files

installation directories:
  --prefix=PREFIX        installation directory
  --bindir=DIR           user executables [EPREFIX/bin]
  --sbindir=DIR          system admin executables [EPREFIX/sbin]
  --libexecdir=DIR       program executables [EPREFIX/libexec]
  --sysconfdir=DIR       read-only single-machine data [PREFIX/etc]
  --sharedstatedir=DIR   modifiable architecture-independent data [PREFIX/com]
  --localstatedir=DIR    modifiable single-machine data [PREFIX/var]
  --libdir=DIR           object code libraries [EPREFIX/lib]
  --shlibdir=DIR         shell script libraries [LIBDIR/sh]

data directories:
  --portsdir=DIR         software ports directory [PREFIX/ports]
  --pkgdir=DIR           software package directory [PREFIX/pkg]
" 1>&2

  test -n "$2" && ${quiet+true} echo "error: $2"

  exit ${1-0}
}

# setup <arguments...>
#
# main program.
# ---------------------------------------------------------------------------
setup()
{
  setup_toolchain
  setup_init "$@"
  setup_dirs
  setup_config
 
  ${quiet+true} echo "Building for ${host:+"host $host and "}installation in $prefix ..." 1>&2

  case $setup_cmd in
    clean)
      setup_clean 'lib'
    ;;
  esac

  case $setup_cmd in
    build | install)
      setup_build ./lib '*.sh.in'
      setup_build ./src '*.sh.in' '*.in'
    ;;
  esac

  case $setup_cmd in
    install)
      # proceed to the installation
      if : || [ "`id -u`" = 0 -o "`uname -o`" = Cygwin ]; then
        setup_install
      else
        echo "You must be root (uid=0) to install libswsh in $prefix" 1>&2
      fi
    ;;
  esac
}

# ===========================================================================
case `basename "$0"` in
  setup | setup.sh)
    setup "$@"
  ;;
esac
