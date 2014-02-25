match-devices()
{ 
    ( EXPR="$*";
    foreach-partition 'case $DEV:$TYPE:$UUID:$LABEL in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV: TYPE=\"$TYPE\" UUID=\"$UUID\" LABEL=\"$LABEL\"" ;; esac' )
}
