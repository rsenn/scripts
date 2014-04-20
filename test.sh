#!/bin/bash

set -e

enable -d csv 2>/dev/null || true
enable -f .libs/csv.so csv

IFS="
"

_csv_field()
{
:  echo "CSV field: $@" 1>&2
}

_csv_row()
{
  echo "CSV row: $@" 1>&2
}

#csv -t -d ';' -F_csv_field -R_csv_row <test.csv

csv -t -d";" -g"2:1" <test.csv

