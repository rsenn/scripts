find-media()
{
    grep --color=auto --color=auto -iE "$(grep-e-expr "$@")" /{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}/files.list 2> /dev/null | filter-files-list | filter-test -e
}
