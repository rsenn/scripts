shiftv()
{
  I=${2:-1}
  
    eval "while [ \$((I)) -gt 0 ]; do case \"\${$1}\" in
    *[\$IFS]*) $1=\"\${$1#*[${IFS}]}\" ;;
  *) $1=\"\" ;;
esac 
    : \$((I--))
  done"
}
