filezilla_location () 
{ 
    ( IFS="/";
    function add () 
    { 
        O="${O:+$O }$*"
    };
    for PART in $*;
    do
        case "$PART" in 
            "")
                add "1 0"
            ;;
            *)
                add "$(str_length "$PART") $PART"
            ;;
        esac;
    done;
    echo "$O" )
}
