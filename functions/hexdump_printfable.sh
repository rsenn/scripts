hexdump-printfable()
{
    . require str;
    hexdump -C -v < "$1" | sed "s,^\([0-9a-f]\+\)\s\+\(.*\),\2 #0x\1, ; #s,0x0000,0x," | sed "s,|[^|]*|,, ; s,^, ," | sed "s,\s\+\([0-9a-f][0-9a-f]\), 0x\\1,g" | sed "s,^,printf \"$(str_repeat 16 %c)\\\n\" ,"
}
