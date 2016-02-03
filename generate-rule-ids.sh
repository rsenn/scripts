#!/bin/sh

THISDIR=`dirname "$0"`

test -n "$2" && exec >$2

i=1

$THISDIR/list-rule-names.sh shell_grammar.hpp |
while read rule_name
do
  printf "    %-25s // %d\n" "${rule_name}_id," "$i"

  i=`expr $i + 1`
done 
