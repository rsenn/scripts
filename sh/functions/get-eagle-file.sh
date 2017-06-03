get-eagle-file () 
{ 
    tasklist /fi "IMAGENAME eq eagle*" /v /fo list 2>&1 | sed -n 's,\\,/,g; s,\r*$,,; /Window Title:/ s,.* - \(.*\) - EAGLE.*,\1,p'
}
