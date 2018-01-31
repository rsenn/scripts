bitrate()
{
  mminfo "$@" | while read -r LINE; do
    INFO=${LINE##*:}
    KEY=${INFO%%=*}
    [ "$KEY" = "Overall bit rate" ] || continue 
    VALUE=${INFO#$KEY=*}
    [ "$INFO" = "$LINE" ] && FILE= || FILE=${LINE%%":$INFO"}
   
    #VALUE=$(suffix-num "${VALUE%"b/s"}")
    VALUE=${VALUE%"b/s"}
    VALUE=${VALUE/" "/""}
    echo "${FILE:+$FILE:}$VALUE"
  done
}
