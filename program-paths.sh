#!/bin/bash

[ -n "$MSYSTEM" ] && OS="Msys"

: ${OS=`uname -o 2>/dev/null || uname -s 2>/dev/null`}
echo "OS is $OS" 1>&2
case "$OS" in
   msys* | Msys* | MSYS*)
     PS1='\[\e]0;$MSYSTEM\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
     MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   ;;
    *cygwin* |Cygwin | CYGWIN*) 
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
  ;;
   *) 
  MEDIAPATH="/m*/*/"
 ;;
esac

eval "ls -d $MEDIAPATH/{Program*/*/*.exe,Tools/*.exe,PortableApps/*/*.exe} 2>/dev/null" |
sed -u 's,/[^/]*$,,'|
uniq |
#sort -u |
{ unset PREV
  while read -r DIR; do
    case "$DIR":"$PREV" in
      "${PREV:-/blah///}"/*:*) ;;
      "$PREV":*) ;;
      *:"${DIR:-/blah///}"/*) PREV="$DIR" ;;
      *) echo "$DIR"
         PREV="$DIR"
         ;;
         esac
     done ; }

