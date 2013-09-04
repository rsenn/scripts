absdir()
{ 
    case $1 in 
        /*)
            echo "$1"
        ;;
        *)
            ( cwd=`pwd` && cd "$cwd${1:+/$1}" && echo "$cwd${1:+/$1}" || { 
                cd "$1" && pwd
            } )
        ;;
    esac 2> /dev/null
}
