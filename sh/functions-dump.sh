#!/bin/bash

str_triml() 
{ 
    local s=$1 t x=${2-${IFS:-$space$nl$tabstop}};
    while t="${s#[$x]}" && test "$t" != "$s"; do
        s="$t";
    done;
    echo "$s"
}

script_getfn() 
{ 
    local fn=$1;
    shift;
    ${SED-sed} -n -e "/$fn\s*()/ {
            s,^, ,

            /[^-0-9A-Za-z]$fn\s*()/ {
              :lp1
              N
              /{/! { b lp1 }
              s,.*[^-0-9A-Za-z]\($fn\s*().*\),\1,
#              p

              :lp2

              N

              /\n}\s*$/! { b lp2; }

              p
              
            }
            q
          }" "$@"
}

script_fnlist() 
{ 
    ( expr="\\([A-Za-z_][-A-Za-z0-9_]*\\)\\s*()" ob='{' cb='}';
    script_nocomments "$@" | ${SED-sed} -n "/$expr/ {
      s/^.*[^-\$_0-9A-Za-z]$expr/\1/
      
      /^$expr/ {
        :lp2
        /^$expr\s*$ob/! { N; b lp2; }
        s,\s*()\s*$ob,\n$ob,
        P
      }
    }" "$@" )
}

script_nocomments() 
{ 
    ${SED-sed} -n -e "/^\s*#/! p" "$@"
}

fn_add_body()
{
  (if [ $# -le 0 ]; then
     read -r FNBODY
   fi
   FNBODY=` str_triml "$FNBODY"` 
   cat <<EOF 
$2()
{
  $FNBODY
}
EOF
  )
}
fn_remove_body()
{
  (if [ $# -le 0 ]; then
     read -r FNBODY
   fi
   FNBODY=${FNBODY#*"{"}
   FNBODY=${FNBODY%"}"*}

   echo "$FNBODY"|${SED-sed} -u 's,^    ,,')
 
}

while :; do
  case "$1" in 
    -d|--dir) OUTPUT_DIR="$2";  shift 2 ;; 
  --dir=) OUTPUT_DIR="${1#*=}";  shift  ;; 
-d*) OUTPUT_DIR="${1#-d}";  shift  ;;
    -c|--compat*) COMPAT_MODE=true; shift ;;
    -p|--pretty*) PRETTY_PRINT=true; shift ;;
    -u|--unindent) UNINDENT=true; shift ;;
    -b|--remove-body) REMOVE_BODY=true; shift ;;
    -r|--regen*-body) REGENERATE_BODY=true; shift ;;
    -s|--shell-shlibprefix) SHELL_PREFIX=true; shift ;;
      *) break ;;
  esac
done

if [ -r "$1" -a -s "$1" ]; then
  INPUT_FILE="$1"
  shift
else
  INPUT_FILE="bash_functions.sh"
fi

: ${OUTPUT_DIR="functions"}

[ -z "$*" ] && set -- $(script_fnlist <$INPUT_FILE)


if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Creating output directory $OUTPUT_DIR ..." 1>&2
  mkdir -p "$OUTPUT_DIR"
fi
 for FN; do 
   OUTPUT_FILE="$OUTPUT_DIR/$FN.sh"
   echo "Dumping function \`$FN' from \`$INPUT_FILE' to $OUTPUT_FILE ..." 1>&2
   FNBODY=$(script_getfn "$FN" <"$INPUT_FILE" )
   [ "$REMOVE_BODY" = true -o "$REGENERATE_BODY" = true ] && FNBODY=$(fn_remove_body "$FNBODY")
   [ "$REGENERATE_BODY" = true ] && FNBODY=$(fn_add_body "$FNBODY" "$FN")
   [ "$UNINDENT" = true ] && FNBODY=$(echo "$FNBODY"|${SED-sed} -u 's,^\s*,,')
   [ "$PRETTY_PRINT" = true ] && FNBODY=$(echo "$FNBODY"|${SED-sed} -u '1 s,\s*(),(),')
   [ "$COMPAT_MODE" = true ] && FNBODY=$(echo "$FNBODY"|${SED-sed} -u 's,^\(\s*\)local\(\s*\),\1\2,')

   if [ "$FNBODY" ]; then
    ([ "$SHELL_PREFIX" = true ] && echo -e '#!/bin/sh\n'; echo "$FNBODY") >"$OUTPUT_FILE"
 fi
   done
