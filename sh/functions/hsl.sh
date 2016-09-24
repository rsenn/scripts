hsl()
{
    ( h=$(( $1 * 360 / 255 ));
    s=$2 l=$3;
    while [ "$h" -lt 0 ]; do
        h=$((h+360));
    done;
    while [ "$h" -gt 360 ]; do
        h=$((h-360));
    done;
    if [ "$h" -lt 120 ]; then
        rsat=$(( (120-h) ));
        gsat=$(( h ));
        bsat=$(( 0 ));
    else
        if [ "$h" -lt 240 ]; then
            rsat=$(( 0 ));
            gsat=$(( (240-h) ));
            bsat=$(( (h-120) ));
        else
            rsat=$(( (h-240) ));
            gsat=$(( 0 ));
            bsat=$(( (360-h) ));
        fi;
    fi;
    rsat=$(min $rsat 60);
    gsat=$(min $gsat 60);
    bsat=$(min $bsat 60);
    echo $rsat $gsat $bsat;
    rtmp=$(( 2*${s}*${rsat}+(255-s) ));
    gtmp=$(( 2*${s}*${gsat}+(255-s) ));
    btmp=$(( 2*${s}*${bsat}+(255-s) ));
    echo $rtmp $gtmp $btmp;
    if [ "$l" -lt 255 ]; then
        r=$(( l*rtmp/65535 ));
        g=$(( l*gtmp/65535 ));
        b=$(( l*btmp/65535 ));
    else
        r=$(( ((255-l)*rtmp+2*l)/65535 ));
        g=$(( ((255-l)*gtmp+2*l-255)/65535 ));
        b=$(( ((255-l)*btmp+2*l-255)/65535 ));
    fi;
    echo $r $g $b )
}
