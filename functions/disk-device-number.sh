disk-device-number()
{ 
    index-of "$(disk-device-letter "$1")" abcdefghijklmnopqrstuvwxyz
}
