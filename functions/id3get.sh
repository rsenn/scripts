id3get()
{ 
    ( id3dump "$1" 2>&1 | grep "^$2" | sed 's,^[^:=]*[:=]\s*,,' )
}
