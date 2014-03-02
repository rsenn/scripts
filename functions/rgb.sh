rgb()
{ 
    ( c=${1#'#'};
    r=$(( 0x${c:0:2} ));
    g=$(( 0x${c:2:2} ));
    b=$(( 0x${c:4:2} ));
    [ "${c:6:2}" ] && a=$(( 0x${c:6:2} )) || a=;
    case "$2" in 
        r)
            echo $((r))
        ;;
        g)
            echo $((g))
        ;;
        b)
            echo $((b))
        ;;
        a)
            echo $((a))
        ;;
        y)
            echo $(( (($r + $g + $b) + 2) / 3 ))
        ;;
        yuv)
            y=$(( ((66*${r}+129*${g}+25*${b}+128)>>8)+16 ));
            u=$(( ((-38*${r}-74*${g}+112*${b}+128)>>8)+128 ));
            v=$(( ((112*${r}-94*${g}-18*${b}+128)>>8)+128 ));
            echo $y $u $v
        ;;
        hsl)
            min=$(min $r $g $b);
            max=$(max $r $g $b);
            if [ ! "$min" -eq "$max" ]; then
                if [ "$r" -eq "$max" -a "$g" -ge "$b" ]; then
                    h=$(( (g-b)*85/(max-min)/2 ));
                else
                    if [ "$r" -eq "$max" -a "$g" -lt "$b" ]; then
                        h=$(( (g-b)*85/(max-min)/2+255 ));
                    else
                        if [ "$g" -eq "$max" ]; then
                            h=$(( (b-r)*85/(max-min)/2+85 ));
                        fi;
                    fi;
                fi;
            fi;
            l=$(( (min+max) / 2 ));
            if [ "$min" -eq "$max" ]; then
                s=0;
            else
                if [ "$((min+max))" -lt 256 ]; then
                    s=$(( (max-min)*256/(min+max) ));
                else
                    s=$(( (max-min)*256/(512-min-max) ));
                fi;
            fi;
            echo $h $s $l
        ;;
        *)
            echo $(($r)) $(($g)) $(($b)) ${a:+$(($a))}
        ;;
    esac )
}
