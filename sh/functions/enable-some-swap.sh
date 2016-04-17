enable-some-swap()
{
  NL="
"
    ( SWAPS=` blkid|${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} 'TYPE="swap"'|cut -d: -f1 `;
    set -- $SWAPS;
    for SWAP in $SWAPS;
    do
        if swapon "$SWAP"; then
            echo "Enabled swap device $SWAP" 1>&2;
            break;
        fi;
    done )
}
