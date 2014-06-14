hex_to_dec()
{
    eval 'echo $((0x'${1%% *}'))'
}
