pid-args()
{ 
    ( for ARG in "$@";
    do
        ( pgrep -f "$ARG" | sed 's,^,-p,' );
    done )
}
