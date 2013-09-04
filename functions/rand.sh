rand()
{ 
    local rot=$(( ${random_seed:-0xdeadbeef} & 0x1f ));
    local xor=`expr ${random_seed:-0xdeadbeef} \* (${random_seed:-0xdeadbeef} "<<" $rot)`;
    random_seed=$(( ( $(bitrotate "${random_seed:-0xdeadbeef}" "$rot") ^ $xor) & 0xffffffff ));
    expr "$random_seed" % ${1:-4294967296}
}
