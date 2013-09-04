id3get()
{ 
    ( id3dump "$1" | grep --color=auto --color=auto --color=auto "^$2" | sed 's,^[^=]*=,,' )
}
