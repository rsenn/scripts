rangearg()
{ 
    ( S="$1";
    E="$2";
    shift 2;
    eval set -- "\${@:$S:$E}";
    echo "$*" )
}
