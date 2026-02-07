count1 () 
{ 
    qjs -e "print('${1}'.split('').filter(i => i=='1').length)"
}
