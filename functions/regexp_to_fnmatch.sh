regexp_to_fnmatch()
{ 
    ( expr=$1;
    case $expr in 
        '^'*)
            expr="${expr#^}"
        ;;
        *)
            expr="*${expr}"
        ;;
    esac;
    case $expr in 
        *'$')
            expr="${expr%$}"
        ;;
        '*')

        ;;
        *)
            expr="${expr}*"
        ;;
    esac;
    case $expr in 
        *'.*'*)
            expr=`echo "$expr" | sed "s,\.\*,\*,g"`
        ;;
    esac;
    case $expr in 
        *'.'*)
            expr=`echo "$expr" | sed "s,\.,\?,g"`
        ;;
    esac;
    echo "$expr" )
}
