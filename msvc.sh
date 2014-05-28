#!/bin/sh
#
# Wrapper for the MSVC++ compiler, making it behave like GNU C.
#
# Copyright (C) 2007 - DigitAll Vertrieb

# Directories of the build system
# -------------------------------------------------------------------------
prefix="/usr"
libdir="$prefix/lib"
shlibdir="$libdir/sh"

# Shell script libraries
# -------------------------------------------------------------------------
. $shlibdir/util.sh
. $shlibdir/std/array.sh
. $shlibdir/std/var.sh

IFS="
$array_s"
var_s="
"



# Visual C++ compiler directories 
# -------------------------------------------------------------------------
find_vc() {
  set -- ${@-`ls -d -- "c:/Program Files"*"/Microsoft Visual Studio "*"/VC/bin/cl.exe"`}
  eval "VC_cl=\"\${$#}\""
  
	VC_target="vc80"
	VC_dir=${VC_cl%/bin/*}
	VC_prefix=`$PATHTOOL "${VC_dir}"`
	VC_bindir="$VC_prefix/bin"
	VC_libdir="$VC_dir/lib"
	VC_includedir="$VC_dir/include"
	
	if ${DEBUG-false}; then
	  var_dump VC_{target,prefix,dir,bindir,libdir,includedir} 1>&2 
	fi
}

# Visual Studio IDE directories
# -------------------------------------------------------------------------
find_ide() {
  set -- ${@-`ls -d -- "${VC_dir%/VC*}/"*"/IDE"`}
  eval "IDE_dir=\"\${$#}\""
	IDE_prefix=`$PATHTOOL "$IDE_dir"`
	
	if ${DEBUG-false}; then
	  var_dump IDE_{dir,prefix} 1>&2 
	fi
	
	pathmunge "$("$PATHTOOL" "$IDE_dir")" after
	
	var_dump PATH 1>&2
}

# Microsoft Platform SDK directories
# -------------------------------------------------------------------------
find_psdk() {
  set -- ${@-`ls -d --  "c:/Program Files"*"/Microsoft SDKs/Windows"/v*`}
  eval "PSDK_dir=\"\${$#}\""
 
	PSDK_prefix=`$PATHTOOL "$PSDK_dir"`
	PSDK_bindir="$PSDK_prefix/bin"
	PSDK_libdir="$PSDK_dir/lib"
	PSDK_includedir="$PSDK_dir/include"
	PSDK_libs="advapi32.lib"
	
	if ${DEBUG-false}; then
	  var_dump PSDK_{prefix,dir,bindir,libdir,includedir,libs} 1>&2 
	fi
}

# Cygwin directories
# -------------------------------------------------------------------------
find_cygwin() {
	set -- ${@-`reg query 'HKEY_CURRENT_USER\Software\Cygwin\Installations' |
	  sed -n "/REG_SZ/ { s/.*REG_SZ\\s\\+// ; p }"`}

	eval "CYGWIN_prefix=\"\${$#}\""

	CYGWIN_dir="$CYGWIN_prefix"
	CYGWIN_bindir="$CYGWIN_prefix/bin"
	CYGWIN_libdir="$CYGWIN_prefix/lib"
	CYGWIN_includedir="$CYGWIN_prefix/include"
	CYGWIN_libs="-lcygwin"
	
	if ${DEBUG-false}; then
	  var_dump CYGWIN_{prefix,dir,bindir,libdir,includedir,libs} 1>&2 
	fi
}

# Compilation target configuration
# -------------------------------------------------------------------------
configure_target() {
	TARGET_compiler="$VC_dir/bin/cl.exe"
	TARGET_optchar="/"
	#WINE="$libdir/wine/wine.bin"
}

# Environment variable configuration
# -------------------------------------------------------------------------
configure_env() {
	ENV_path="$VC_bindir:$IDE_prefix:$PSDK_bindir"
	ENV_include="$VC_includedir;$PSDK_includedir"
	ENV_lib="$VC_libdir;$PSDK_libdir"
}

# Wrapper info
# -------------------------------------------------------------------------
PROGNAME=${0##*/}

# Wrapper behaviour
# -------------------------------------------------------------------------
DEBUG=true
OUTEXT=false
PDB=false

# ------------------------------------------------------------------------- #
# DON'T CHANGE BEYOND THIS LINE UNLESS KNOWING EXACTLY WHAT YOU'RE DOING!!! #
# ------------------------------------------------------------------------- #

# script_restart <args>
#
# Restarts this script.
# ------------------------------------------------------------------------- #
script_restart()
{
  exec "$0" "$@"
}

# psdk_config <platform-sdk-dir> [standard-libraries...]
#
# Set the Platform SDK configuration variables based on the given 
# installation path.
# -------------------------------------------------------------------------
psdk_config() {
  PSDK_prefix=`cygpath "$1"`
  PSDK_dir=`cygpath -m "$1"`
  PSDK_bindir=$PSDK_prefix/bin
  PSDK_libdir=$PSDK_prefix/lib
  PSDK_includedir=$PSDK_prefix/include
  PSDK_libs=${2-advapi32.lib}
}

# msvc_infer <arguments...>
#
# Determine compilation MSVC_mode & output file type.
# ------------------------------------------------------------------------- #
msvc_infer()
{
  local ARG e MSVC_mode="link" OUTNAME OUTTYPE="exe" INNAME intype debug=0 

  for ARG; do
    case $ARG in
      [-/]c) 
        MSVC_mode="compile" 
        MSVC_outtype="obj" 
      ;;

      [-/][EP]*)
        MSVC_mode="preproc"
        MSVC_outtype="pp"
      ;;

      -S)
        MSVC_mode="assemble"
        MSVC_type="asm"
      ;;
      
      # Handle debugging options.
      -g) 
        [ "$MSVC_debug" -lt 3 ] && MSVC_debug=`expr $MSVC_debug + 1` 
      ;;

      -g[0-3])
        MSVC_debug="${ARG#-g}"
      ;;

      -ggdb)
        MSVC_debug=3 
      ;;

      # Option for compiling ARG shared library (DLL)
      [-/]LD*)
        if [ "$MSVC_type" = exe ]; then
          MSVC_type="dll"
        fi
        ;;
        
      # unknown argument
      -*|/*)
        ;;
    esac
  done
}

# msvc_serialize [prefix...]
#
# ------------------------------------------------------------------------- #
msvc_serialize()
{
  echo "${1+$1_}MSVC_mode=$MSVC_mode"
  echo "${1+$1_}outfile=$msvc_outfile"
  echo "${1+$1_}OUTTYPE=$MSVC_outtype"

}

# read_var <name> <files...>
#
# Reads ARG variable from ARG file.
# ------------------------------------------------------------------------- #
read_var()
{
  local name=$1 && shift

  sed -n "/^$name=/ {
    /^$name='[^']*'\$/    s/^$name='\([^']*\)'\$/\1/ p
    /^$name=\"[^\"]*\"\$/ s/^$name=\"\([^\"]*\)\"\$/\1/ p
    /^$name=[^'\"]*\$/    s/^$name=\([^'\"]*\)\$/\1/ p
  }" "$@"
}

# msvc_outopt <name> [MSVC_mode] [type]
#
# Outputs ARG command line option which sets the output name for
# the corresponding MSVC_mode.
# ------------------------------------------------------------------------- #
msvc_outopt()
{
  local OPT="" MSVC_mode=${2-"$MSVC_mode"} type=${3-"$MSVC_type"}

  case $MSVC_mode in
    compile) OPT="${TARGET_optchar}Fo$1" ;;
    assemble) OPT="${TARGET_optchar}Fa$1" ;;
    preproc) ;;
    *) OPT="${TARGET_optchar}Fe$1" ;;
  esac


  if test -n "$OPT"
  then 
    if $OUTEXT
    then
      echo "$OPT${type:+.$type}"
    else
      echo "$OPT"
    fi
  fi
}

# msvc_relative <path>
#
# Convert absolute path to relative one.
# This is done on any absolute path argument to disambiguate them from command line
# switches.
# ------------------------------------------------------------------------- #
msvc_relative()
{
  local IFS="/" dir cwd=$(pwd) path=$*

  for dir in ${cwd#/}
  do
    path="../${path#/}"
  done
  
  echo "$path"
}

# msvc_main <args>
# ------------------------------------------------------------------------- #
msvc_main()
{
#  IFS="$array_s"
  
  msvc_infer "$@"
  msvc_optimize=1
  msvc_dll=false
  msvc_ldflags=false

  unset msvc_sources
  unset msvc_link
  
  i=0
  prev=
  args=$*

	find_vc
	find_ide
	find_psdk
	find_cygwin
	configure_target
	configure_env
    
  for arg; do
      test $((i++)) = 0 && set --
    
    if $msvc_ldflags
    then
      case $arg in
        -dll)
          msvc_dll=true
          ;;
        *)
          array_push msvc_link "$arg"
          ;;
      esac

      continue
    fi
    
    case $prev in
      # Last argument was -o, so this argument is the output filename.
      [-/]o) arg=$(msvc_outopt "$arg") && unset prev ;;
      [-/][DI]) arg="${TARGET_optchar}${prev#-}$arg" && unset prev ;;
      -L) ENV_lib="$ENV_lib;$arg" && unset arg && unset prev ;;
      -l) array_push msvc_link "$arg.lib" && unset arg && unset prev ;;
      [-/]LINK) array_push msvc_link "$arg" && unset arg && unset prev ;;
      
      *)
        case $arg in
          # Dump machine
          [-/]dumpmachine)
            echo "$VC_target"
            exit 0
            ;;
        
          # Void options...
          [-/]traditional-cpp | [-/][Nn][Oo][Ll][Oo][Gg][Oo])
            unset arg
            ;;
        
          # Options which take arguments...
          [-/][DILlo]) 
            prev="$arg"
            continue
            ;;
  
          # Options without args...
          [-/][cE])
            arg="${TARGET_optchar}${arg#[-/]}"
            ;;

          [-/][Ll][Ii][Nn][Kk])
            msvc_ldflags=true
#            prev="${TARGET_optchar}LINK"
            continue
            ;;
      
          # Options which change env vars...
          -L*)
            ENV_lib="$ENV_lib;${arg#-L}"
            continue
#            arg="-LIBPATH:${arg#-L}"
            ;;
  
          # Link ARG library...
          -l*)
#            arg="${arg#-l}.lib"
            array_push msvc_link "${arg#-l}.lib"
            continue
            ;;

          # Options which map transparently...
          [-/][DI]* | [-/]MD*)
            arg="${TARGET_optchar}${arg#[-/]}"
            ;;
  
          # Set the output filename.
          [-/]o* | [-/]F[eo]*)
            msvc_output="${arg#[-/]o}"
            msvc_output="${msvc_output#[-/]F[eo]}"
            arg=$(msvc_outopt "$msvc_output") || continue
            ;;
  
          # Compiler warnings
          [-/]Wall | [-/]W[23])
            arg="${TARGET_optchar}Wall"
            ;;
  
          [-/]WX | -Werror) 
            arg="${TARGET_optchar}WX"
            ;;
      
          # Optimization flags
          [-/]O[0-3bdgistxy])
            msvc_optimize=${arg#[-/]O}
            
            case $msvc_optimize in
              s) msvc_optimize=$(array "1" "s") ;;
              0) msvc_optimize="d" ;;
              1) msvc_optimize=$(array "1" "t") ;;
              2) msvc_optimize=$(array "2" "t" "i") ;;
              3) msvc_optimize=$(array "2" "x" "i" "b1") ;;
              *) array_push msvc_optimize "$msvc_optimize" ;;
            esac
            
            unset arg
            ;;
      
          # Debugging flags
          -g*)
            case $prev in
              -g*) ;;
              *)
                case $MSVC_debug in
                  0) arg= ;;
                  1) arg=$(array "${TARGET_optchar}Zi") ;;
                  2) arg=$(array "${TARGET_optchar}Zi" "${TARGET_optchar}Yd") ;;
                  3) arg=$(array "${TARGET_optchar}Zi" "${TARGET_optchar}ZI" "${TARGET_optchar}Yd") ;;
                esac
                ;;
            esac
            
            if ! $PDB
            then
              unset arg
            fi
            ;;
      
          # Linker options
          [-/]LD | -shared | -mdll)
            arg="${TARGET_optchar}LD"
            ;;
            
          # Help options
          [-/][Hh][Ee][Ll][Pp])
            arg="${TARGET_optchar}HELP"
            ;;
      
          # Any other option
          -*)
            echo "Unrecognized option: $arg" 1>&2
            exit 1
            ;;
        
          # Non-option arguments
          *)
            source_path="$arg"
            source_file=$(basename "$arg")
            source_dir=$(dirname "$arg")
            
            case $source_file in
              lib*.ARG)
                 array_push msvc_link "$source_path"
                 continue
#                source_file=${source_file#lib}
#                source_file=${source_file%.ARG}.lib
                ;;
            esac
            
            case $source_dir in
              /*) source_dir=$(msvc_relative "$source_dir") ;;
            esac
            
            case $source_dir in
              .) source_path="$source_file" ;;
              *) source_path="$source_dir/$source_file" ;;
            esac
          
            array_push msvc_sources "$source_path"
            unset arg
            continue
            ;;
        esac
      ;;
    esac
    
  
    set -- "$@" ${arg+$arg}
  
  done
  
  # Second pass, adjusting some switches...
  i=0
  
  for arg
  do
    test $((i++)) = 0 && set --
  
    case $arg in
      /LD | /M[DT])
        # On debugging MSVC_mode greater than 1 we also instruct the linker..
        if test $((MSVC_debug)) -gt 1
        then
          arg="${arg}d"
        fi
        ;;
    esac
  
    set -- "$@" $arg
  done
  
  # Never display microsoft banner..
#  set -- "/nologo" "$@"
  
  # Set optimization, if any...
  if [ -n "$msvc_optimize" -a "$msvc_optimize" != d ]; then
    for OPT in $msvc_optimize; do
      set -- "$@" "${TARGET_optchar}O$OPT"
    done
  fi
  
  # Add the list of sources...
  set -- "$@" $msvc_sources
  
  # Add option forcing C++ compilation...
  case $PROGNAME in
    [cg]++ | *-[cg]++)
      set -- "${TARGET_optchar}TP" "$@"
      ;;
  esac

  # Add dll linker option
  if $msvc_dll
  then
    if test $((MSVC_debug)) -gt 1
    then
      set -- "$@" "${TARGET_optchar}LDd"
    else
      set -- "$@" "${TARGET_optchar}LD"
    fi
  fi

  # Add linker options
  if test -n "$msvc_link"
  then
#    set -- "$@" "/LINK" $msvc_link
    set -- "$@" $msvc_link 
    
    set -- "$@" $PSDK_libs
  fi

  # Finally execute the compiler..
#  set -- env -i PATH="$ENV_path" LIB="$ENV_lib" INCLUDE="$ENV_include" "$TARGET_compiler" "$@"
  set -- "$TARGET_compiler" "$@"
  
 
  if $DEBUG
  then
    echo "CMD: $@"
  fi

#  exec "$@"

  (
  
  PATH="$ENV_path" LIB="$ENV_lib" INCLUDE="$ENV_include"
  export PATH LIB INCLUDE
  
  if ${DEBUG-false}; then
    var_dump PATH LIB INCLUDE
  fi
  
  if $DEBUG; then set -x; fi
  "$@") || exit $?
  
  return
  msvc_ret=$?

  if $DEBUG
  then
    echo "RET: $msvc_ret"
  fi
  
  return $msvc_ret
}

# -------------------------------------------------------------------------
pathmunge () { 
		echo "pathmunge: $@" 1>&2
    while :; do
        case "$1" in 
            -v)
                PATHVAR="$2";
                shift 2
            ;;
            *)
                break
            ;;
        esac;
    done;
    old_IFS="$IFS"; IFS=":";
    if ! eval "echo \"\${${PATHVAR-PATH}}\"" | egrep -q "(^|:)$1($|:)"; then
        if test "$2" = "after"; then
            eval "${PATHVAR-PATH}=\"\${${PATHVAR-PATH}}:\$1\"";
        else
            eval "${PATHVAR-PATH}=\"\$1:\${${PATHVAR-PATH}}\"";
        fi;
    fi;
    unset PATHVAR
    IFS="$old_IFS"
}

case ${OS=`uname -o`} in 
  [Mm][Ss][Yy][Ss]*) PATHTOOL=msyspath
		#if ! type msyspath; then
			msyspath() {
			  echo "msyspath: $@" 1>&2
				case "$1" in
					?:*) echo "/sysdrive/${1%%:*}${1#?:}" ;;
					*) echo "$*" ;;
				esac
			}
		#fi  
   ;;
  Cygwin) PATHTOOL=cygpath ;;
esac

echo "PATHTOOL=$PATHTOOL" 1>&2

# -------------------------------------------------------------------------
PROG_dir=`dirname "$0"`
PROG_name=`basename "$0"`

case $PROG_name in
  msvc*)
    msvc_main "$@"
  ;;
esac

# ===[ EOF ]===============================================================
