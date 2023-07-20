bits () 
{ 
    qjs -e "print((${1}).toString(2).split('').reverse().map((n,i) => n=='1' ? [n, i] : null).filter(v => v!==null).map(([i,v]) => (1 << v)).join('\n'))"
}
