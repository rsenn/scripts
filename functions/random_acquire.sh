random_acquire()
{
    local n IFS="$newline";
    for n in $(echo "$@" | hexdump -d | sed "s,^[0-9a-f]\+\s*,,;s,\s\+,\n,g");
    do
        local rot=$(( (${random_seed:-0xdeadbeef} + (n >> 11)) & 0x1f)) xor=$((${random_seed:-0xdeadbeef} - (n & 0x07ff)));
        random_seed=$(( ($(bitrotate $(( ${random_seed:-0xdeadbeef} )) $rot) ^ $xor) & 0xffffffff ));
    done;
    echo "seed: ${random_seed:-0xdeadbeef}"
}
