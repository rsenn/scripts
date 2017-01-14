get-volume-list() {
 (

 set -- $(df -l | sed '1d; s|\s\+.*||;  \|^/dev|! { \|^.:|! d }; /^.:/ s|[/\\].*||')
 while [ $# -gt 0 ]; do
     
     
     echo "$1" $(volname "$1")
     shift
 done

 
# set -- $(df -hl|sed -n '\|^/dev/.d| { s,\s.*,, ; s|.*/||; p }'|grep-e-expr)
#  ls -la -d -n --time-style=+%s -- /dev/disk/by-label/* | grep -E "/$(IFS="|"; echo "$*")\$" |
#  { IFS=" "; while read -r MODE N USR GRP SIZE TIME LABEL _A DEVICE; do echo "/dev/${DEVICE##*/}" "${LABEL##*/}"; done; }

)
}


 
