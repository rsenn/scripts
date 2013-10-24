cut-lsof()
{ 
    ( IFS=" ";
    eval "while read -r COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME; do 
  if ( ! [ \"\$NODE\" -ge 0 ] 2>/dev/null ) || [ -z \"\$NAME\" ]; then NAME=\"\$NODE\${NAME:+ \$NAME}\"; unset NODE; fi;   echo \"\${${1-NAME}}\"; done" )
}
