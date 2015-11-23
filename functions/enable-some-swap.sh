enable-some-swap()
{
    ( SWAPS=` blkid|${GREP-grep} 'TYPE="swap"'|cut -d: -f1 `;
    set -- $SWAPS;
    for SWAP in $SWAPS;
    do
        if swapon "$SWAP"; then
            echo "Enabled swap device $SWAP" 1>&2;
            break;
        fi;
    done )
}
