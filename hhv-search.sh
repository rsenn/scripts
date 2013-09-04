#!/bin/bash

: ${prefix="/usr"}
: ${libdir="$prefix/lib"}
: ${shlibdir="$libdir/sh"}

. $shlibdir/util.sh
. $shlibdir/std/algorithm.sh
. $shlibdir/std/array.sh
. $shlibdir/std/var.sh
. $shlibdir/algorithm/escape.sh
. $shlibdir/shell/bash.sh
. $shlibdir/data/xml.sh
. $shlibdir/net/http.sh

bash_enable 'csv'

ME=$(readlink "$0")
MY_PATH=`dirname "$ME"`

q=$(echo "$*" | sed 's, ,+,g')

http_get "www.hhv.de/index.php?action=topSearch&match=$q" |
tee "hhv-search.html" |
xml_get "a href=\"item_[^>]*" | 
sed -n -e 's,.*_\([0-9]\+\)\..*,\1,p' | {
#set -x
IFS="
"
  echo "artist;album;hhv_sku;pressung;format_type;release_year;label;genre;tracklist"
while read hhv_sku
do
  xml=$(ruby /home/enki/playground/scrubyt/hhv_detail_extractor.rb "http://www.hhv.de/item_$hhv_sku.html" 2>/dev/null)


  artist=$(echo "$xml" | xml_value 'artist')
  album=$(echo "$xml" | xml_value 'album')
  hhv_sku=$(echo "$xml" | xml_value 'hhv_sku')
  pressung=$(echo "$xml" | xml_value 'pressung')
  format_type=$(echo "$xml" | xml_value 'format_type')
  release_year=$(echo "$xml" | xml_value 'release_year')
  label=$(echo "$xml" | xml_value 'label')
  genre=$(echo "$xml" | xml_value 'genre')

  tracklist_numbers=$(echo "$xml" | xml_value 'tracklist_number') 
  tracklist_titles=$(echo "$xml" | xml_value 'tracklist_titles')

# var_dump artist album hhv_sku pressung format_type release_year label genre

  tracklist=

  while test `array_count tracklist_numbers` -gt 0
  do
    number=$(array_index tracklist_numbers 0); array_shift tracklist_numbers
    title=$(array_index tracklist_titles 0); array_shift tracklist_titles
    
    pushv tracklist "$number. $title"
  done


  echo "$xml" 1>&2

  csv -d';' \
      "$artist" \
      "$album" \
      "$hhv_sku" \
      "$pressung" \
      "$format_type" \
      "$release_year" \
      "$label" \
      "$genre" \
      "$tracklist"

done



}

