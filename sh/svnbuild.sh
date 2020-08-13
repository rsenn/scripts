#!/bin/sh
#
# -*-mode: shell-script-*-
#
# svnbuild.sh
#
# Copyright (c) 2008  <enki@vinylz>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-11-20  <enki@vinylz>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${shlibprefix="/usr"}
: ${libdir="$shlibprefix/lib"}
: ${shlibdir="$libdir/sh"}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/buildsys.sh

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags

DEFINE_boolean help          "$FLAGS_FALSE" "show this help" h
DEFINE_boolean debug         "$FLAGS_FALSE" "enable debug mode" D
DEFINE_string  inputfile     "-"         "input file" i
DEFINE_string  shlibprefix        ""          "install architecture-independent files in PREFIX"
DEFINE_string  sysconfdir    ""          "read-only single-machine data [PREFIX/etc]"
DEFINE_string  localstatedir ""          "modifiable single-machine data [PREFIX/var]"
DEFINE_string  host          ""          "cross-compile to build programs to run on HOST [BUILD]"
DEFINE_string  build         ""          "configure for building on BUILD [guessed]"
DEFINE_string  target        ""          "configure for building compilers for TARGET [HOST]"


FLAGS_HELP="usage: `basename "$0"` [flags] <url>
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# svnbuild_usage
# ---------------------------------------------------------------------------                                                  
svnbuild_usage()
{
  flags_help
}

# svnbuild_name <url>
# ---------------------------------------------------------------------------                                                  
svnbuild_name()
{
  url=$1
  base=${url##*/}

  case $base in 
    trunk)
      url="${url%/$base}"
      base="${url##*/}-$base"
    ;;
  esac  

  echo "$base"
}

# Main program
# --------------------------------------------------------------------------- 
svnbuild()
{
  IFS="
"
  if [ -z "$1" ]; then
    svnbuild_usage
    exit 1
  fi  

  # now here do something
  URL=$1
  NAME=`svnbuild_name "$URL"`

  msg "Building in '$NAME'"

  set -e

  svn co "$URL" "$NAME"

  cd "$NAME"

  BUILDSYS=`buildsys_detect .`

  BOOTSTRAP=
  CONFIGURE=
  BUILD=

  case $BUILDSYS in
    autotools)
      for script in autogen.sh bootstrap bootstrap.sh; do
        if [ -e "$script" ]; then
          if [ -x "$script" ]; then
            BOOTSTRAP="./$script"
          else
            BOOTSTRAP="sh $script"
          fi
          break
        fi  
      done
    ;;
    *)
      error "No such build system '$BUILDSYS'"
    ;;
  esac   

  if [ -n "$BOOTSTRAP" ]; then
    msg "Running" $BOOTSTRAP
    $BOOTSTRAP
  fi

  case $BUILDSYS in
    autotools)
      if [ -x configure ]; then
        CONFIGURE="./configure"

        [ "$FLAGS_prefix" ] && pushv CONFIGURE --shlibprefix="$FLAGS_prefix"
        [ "$FLAGS_sysconfdir" ] && pushv CONFIGURE --sysconfdir="$FLAGS_sysconfdir"
        [ "$FLAGS_localstatedir" ] && pushv CONFIGURE --localstatedir="$FLAGS_localstatedir"
      fi
    ;;   
  esac 

  if [ -n "$CONFIGURE" ]; then
    msg "Running" $CONFIGURE
    $CONFIGURE
  fi  

  case $BUILDSYS in
    autotools)
      if [ -e Makefile ]; then
        BUILD="make"
      fi
    ;;
  esac  

  if [ -n "$BUILD" ]; then
    msg "Running" $BUILD
    $BUILD 
  fi  
}

# ---------------------------------------------------------------------------
svnbuild "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
