#!/bin/sh

IFS=:

echo '<table border="1" cellspacing="1" cellpadding="1">'
echo "<tr><th>Code</th><th>Color</th></tr>"

while read color code; do 
  echo "<tr><td>$code</td><td>$color</td></tr>"
done <colors

echo '</table>'


