list()
{ 
<<<<<<< HEAD
    sed "s|/files\.list:|/|"
=======
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
>>>>>>> 920a4a7eb2d8d4ebe7a624d237d7d9aad809de43
}
