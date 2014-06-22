match-mounted()
{
    ( EXPR="$*";
    foreach-mount 'case $DEV:$MNT:$TYPE:$OPTS in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV $MNT $TYPE $OPTS $A $B" ;; esac' )
}
