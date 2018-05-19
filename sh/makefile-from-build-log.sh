#!/bin/bash

TS='	'
NL='
'
vget() {
  (IFS=" ;$NL"; set -- $(var_get "$1" )
  echo "$*")
}

makefile_from_build_log() {                                                                                           
                                                                                                                      
  while :; do                                                                                                         
    case "$1" in                                                                                                      
      *) break ;;                                                                                                     
    esac                                                                                                              
  done                                                                                                                
                                                                                                                      
  while read -r LINE; do                                                                                              
    eval "$LINE"                                                                                                      
    set -- $LINE                                                                                                      
    unset VARS                                                                                                        
    for VAR; do                                                                                                       
      VAR="${VAR%%=*}"                                                                                                
      eval "$VAR='$(vget "$VAR")'"                                                                                    
      pushv VARS "${VAR%%=*}"                                                                                         
    done                                                                                                              

    if [ -n "$DEFINES" ]; then
      DEFS=$(addprefix -D $DEFINES)
      pushv VARS DEFS
  fi
    if [ -n "$SYSINCLUDES" -o -n "$INCLUDES" ]; then
      CPPFLAGS=$(addprefix "-isystem " $SYSINCLUDES)
      CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }$(addprefix -I $INCLUDES)"
      pushv VARS CPPFLAGS
    fi
                                                                                                                      
                                                                                                                      
    #echo $VARS 1>&2                                                                                                  
    addline OUT "$OUTFILE": $ARGS                                                                                     
    addline OUT "${TS}${CMD}" $DEFS  $CPPFLAGS $OPTS ${OUTFILE:+-o \$@} \$^                                                                                         
    addline OUT                                                                                                       
                                                                                                                      
   for V in $VARS; do                                                                                                 
     [ "$V" = "CMD" -o "$V" = OPTS ] && continue
     eval "test \"\$PREV_$V\" = \"\$$V\" && _$V=\"\$$V\""                                                             
     pushv GLOBALS _$V                                                                                                
   done                                                                                                               
                                                                                                                      
                                                                                                                      
   for V in $VARS; do                                                                                                 
     eval "PREV_$V=\$$V"                                                                                              
   done                                                                                                               
 done                                                                                                                 
 for G in $GLOBALS; do                                                                                                
   VALUE=$(var_get "$G")                                                                                              
   VALUE=${VALUE//"$NL"/" "}                                                                                          
   OUT=${OUT//"$VALUE"/"\$(${G#_})"}                                                                                    
                                                                                                                      
   OUT="${G#_} = $VALUE                                                                                               
$OUT"                                                                                                                 
   done                                                                                                               
                                                                                                                      
                                                                                                                      
 echo "$OUT"                                                                                                          
}                                                                         

addline() 
{ 
    eval "shift;$1=\"\${$1+\"\$$1\${NL}\"}\$*\""
}
pushv() 
{ 
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}
addprefix() 
{ 
    ( PREFIX=$1;
    shift;
    CMD='echo "$PREFIX$LINE"';
    [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done";
    eval "$CMD" )
}
var_get() 
{ 
    eval "echo \"\$$1\""
}

makefile_from_build_log "$@"
