#!/bin/sh 

THISDIR=`dirname "$0"`

test -n "$2" && exec >$2

$THISDIR/list-rule-names.sh ${1+"$1"} |
while read rule_name
do
  echo "            rule_names[shell_grammar::${rule_name}_id] = \"$rule_name\";"
done
