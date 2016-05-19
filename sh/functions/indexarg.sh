indexarg()
{
    ( I="$1";
    shift;
    eval echo "\${@:$I:1}" )
}
