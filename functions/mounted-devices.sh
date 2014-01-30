mounted-devices()
{ 
    awkp 1 < /proc/mounts | grep --color=auto --color=auto --color=auto --color=auto -vE '(^none$)'
}
