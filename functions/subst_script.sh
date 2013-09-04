subst_script()
{ 
    local var script value IFS="$obj_s";
    for var in "$@";
    do
        if [ "$var" != "${var%%=*}" ]; then
            value=${var#*=};
            value=`echo "$value" | sed 's,\\\\,\\\\\\\\,g'`;
            array_push script "s°@${var%%=*}@°`array_implode value '\n'`°g";
        else
            value=`var_get "$var"`;
            value=`echo "$value" | sed 's,\\\\,\\\\\\\\,g'`;
            array_push script "s°@$var@°`array_implode value '\n'`°g";
        fi;
    done;
    array_implode script ';'
}
