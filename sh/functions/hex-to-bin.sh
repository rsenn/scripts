hex-to-bin()
{
    local chars=`str_to_list "$1"`;
    local bin IFS="$newline" ch;
    for ch in $chars;
    do
        case $ch in
            0)
                bin="${bin}0000"
            ;;
            1)
                bin="${bin}0001"
            ;;
            2)
                bin="${bin}0010"
            ;;
            3)
                bin="${bin}0011"
            ;;
            4)
                bin="${bin}0100"
            ;;
            5)
                bin="${bin}0101"
            ;;
            6)
                bin="${bin}0110"
            ;;
            7)
                bin="${bin}0111"
            ;;
            8)
                bin="${bin}1000"
            ;;
            9)
                bin="${bin}1001"
            ;;
            a | A)
                bin="${bin}1010"
            ;;
            b | B)
                bin="${bin}1011"
            ;;
            c | C)
                bin="${bin}1100"
            ;;
            d | D)
                bin="${bin}1101"
            ;;
            e | E)
                bin="${bin}1110"
            ;;
            f | F)
                bin="${bin}1111"
            ;;
        esac;
    done;
    echo "$bin"
}
