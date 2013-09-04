#!/bin/bash

SOURCE_DIR=${1:-"functions"}
IFS="
"

unset FUNCTIONS

pushv() 
{ 
      eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

str_triml ()
{   
    local s=$1 t x=${2-${IFS:-$space$nl$tabstop}};
    while t="${s#[$x]}" && test "$t" != "$s"; do
        s="$t";
    done;
    echo "$s"
}
set -- $(ls -tdr $SOURCE_DIR/*.sh)

set -- `echo "$*" |sort -fu` 

for FILE ;  do
  FILENAME=${FILE##*/}
  NAME=${FILENAME%.sh}

  FNBODY=$(sed '1 { s|\s*()\s*$|()| }' "$FILE")
  FNBODY=`str_triml "$FNBODY"` 

 [ "$FUNCTIONS" ] && pushv FUNCTIONS ""

  pushv FUNCTIONS "$FNBODY"
done

echo -e "#!/bin/bash\n"
echo "$FUNCTIONS"