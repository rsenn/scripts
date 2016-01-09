hexdump-printfable()
{
    . require str;
    hexdump -C -v < "$1" | ${SED-sed} "s,^\([0-9a-f]\+\)\s\+\(.*\),\2 #0x\1, ; #s,0x0000,0x," | ${SED-sed} "s,|[^|]*|,, ; s,^, ," | ${SED-sed} "s,\s\+\([0-9a-f][0-9a-f]\), 0x\\1,g" | ${SED-sed} "s,^,printf \"$(str_repeat 16 %c)\\\n\" ,"
}
