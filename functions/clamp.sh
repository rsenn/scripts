clamp()
{ 
    local int="$1" min="$2" max="$3";
    if [ "$int" -lt "$min" ]; then
        echo "$min";
    else
        if [ "$int" -gt "$max" ]; then
            echo "$min";
        else
            echo "$int";
        fi;
    fi
}
