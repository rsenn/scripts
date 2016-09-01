verbose() {
   (M="$*" A=`eval "echo \"\${$#}\""` IFS="
";
    if [ "$#" = 1 ]; then
        A=1;
    fi;
    if ! [ "$A" -ge 0 ]; then
        A=0;
    fi 2> /dev/null > /dev/null;
    if [ $(( ${VERBOSE:-0} )) -ge "$A" ]; then
        M "${M%?$A}";
    fi)
}
