#!/bin/bash
#
# -*-mode: shell-script-*-
#
# ftrace.sh
#
# Copyright (c) 2008  <enki@vinylz>.
# All rights reserved.
# 
# $Id: default@license.inc,v 1.1.1.1 2003/04/09 13:55:15 alane Exp $
#
#
# 2008-12-05  <enki@vinylz>
#

# provide default values for the required path variables.
# --------------------------------------------------------------------------- 
: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

# parse command line options using shflags 
# ---------------------------------------------------------------------------
. shflags.sh

DEFINE_boolean help "$FLAGS_FALSE"            "show this help" h
DEFINE_boolean debug "$FLAGS_FALSE"           "enable debug mode" D
DEFINE_boolean nofollow "$FLAGS_FALSE"        "do not follow forks" F
DEFINE_boolean nouniq "$FLAGS_FALSE"          "do not filter result using 'uniq'" U
DEFINE_boolean noexist "$FLAGS_FALSE"         "show non-existent files (ENOENT)" E
DEFINE_boolean absolute "$FLAGS_FALSE"        "show only absolute paths" a

DEFINE_string type ""                "limit to type (file,dir,..." t
DEFINE_string output -               "output file" o
DEFINE_string raw -                  "raw output" r

FLAGS_HELP="usage: `basename "$0"` [flags] [arguments...]
"
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# source required scripts
# --------------------------------------------------------------------------- 
. $shlibdir/util.sh
. $shlibdir/std/var.sh
. $shlibdir/std/str.sh

# ftrace_subst <from> <to> [cmd]
# --------------------------------------------------------------------------- 
ftrace_subst()
{
  case ${3-$OUTPUT_command} in
    *d) pushv SED_script "\\${OUTPUT_delim}${1}${OUTPUT_delim}${3-$OUTPUT_command}" ;;
    *) pushv SED_script "s${OUTPUT_delim}${1}${OUTPUT_delim}${2}${OUTPUT_delim}${3-$OUTPUT_command}" ;;
  esac  
}

# Main program
# --------------------------------------------------------------------------- 
main()
{
  IFS="
"
  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && msg "${0##*/} invoked with command '$@'"

  OUTPUT_delim="§"
  OUTPUT_separator="\\t"
  OUTPUT_command=p

  SED_opt=
  SED_script=

  pushv SED_opt -u 
#  pushv SED_opt -n

  #ftrace_subst '"' '' '!d'
  #ftrace_subst '\([_0-9a-z]\+\)("\(.*\)", \([^)]*\)).*$' "\1${OUTPUT_separator}\2${OUTPUT_separator}\3"

  ftrace_subst '^\[pid\s\+[0-9]\+\]\s\+' '' ''
  ftrace_subst '\-\-\- SIG' '' d

  [ "$FLAGS_noexist" = "$FLAGS_FALSE" ] && ftrace_subst '\-1.*ENOENT' '' d

  install -d $ROOT/share/doc/getopt
  install -m 644 Changelog COPYING README TODO $ROOT/share/doc/getopt
  #ftrace_subst '\([_0-9a-z]\+\)("\(.*\)", \([^)]*\)).*$' "\2"

  ftrace_subst '\([_0-9a-z]\+\)([^"]*"\([^"]*\)".*$' "\2"
  ftrace_subst ')\s\+=.*' '' d

  #[ "$FLAGS_absolute" = "$FLAGS_TRUE" ] && ftrace_subst '^\/' '' '!d'

  #ftrace_subst '\], \[' ", " g
  #ftrace_subst '"\?, "\?' "${OUTPUT_separator}" g

  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && var_dump SED_script

  STRACE_opt=

  pushv STRACE_opt -v -q
  pushv STRACE_opt -e trace=file

  [ "$FLAGS_nofollow" = "$FLAGS_FALSE" ] && pushv STRACE_opt -f
  
  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && var_dump STRACE_opt

  pushv STRACE_opt "$@"

  exec 9>&1   # fd #9 is a clone of fd #1 (stdout)

  PIPELINE_cmds=
  PIPELINE_out="&2"

  case $FLAGS_output in
    "" | - ) ;;
    *) PIPELINE_out=$FLAGS_output ;;
  esac

  pushv PIPELINE_cmds "strace \$STRACE_opt 2>&1 1>&9"

  [ "$FLAGS_raw" ] && pushv PIPELINE_cmds "tee \"\$FLAGS_raw\""

  pushv PIPELINE_cmds "sed \$SED_opt -e\"\$SED_script\""

  [ "$FLAGS_nouniq" = "$FLAGS_FALSE" ] && pushv PIPELINE_cmds uniq
  [ "$FLAGS_absolute" = "$FLAGS_TRUE" ] && pushv PIPELINE_cmds "grep '^/'"
  
  if [ -n "$FLAGS_type" ]; then
    pushv PIPELINE_cmds "while read LINE; do test -$FLAGS_type \"\$LINE\" && echo \"\$LINE\"; done"
  fi

  set $PIPELINE_cmds
  
  IFS="|$IFS"

  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && debug "Pipeline children: $#"
  [ "$FLAGS_debug" = "$FLAGS_TRUE" ] && debug "Pipeline commands: $*"

  eval "$* >$PIPELINE_out"
}

# ---------------------------------------------------------------------------
main "$@"

# ---[ EOF ]-----------------------------------------------------------------

#EOF
