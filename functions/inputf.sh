inputf()
{ 
    local __line__ __cmds__;
    __line__=$IFS;
    __cmds__="( set -- \$__line__; $*; )";
    IFS="$__line__";
    while read __line__; do
        eval "$__cmds__";
    done
}
