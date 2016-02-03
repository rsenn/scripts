hex-to-dec()
{
    eval 'echo $((0x'${1%% *}'))'
}
