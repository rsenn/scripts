shortcut-cmd() {
    readshortcut -a -f "$1" | sed 's,^Arguments:\s*\(.*\),-a\n"\1",
    s,^Description:\s\+\(.*\),-d\n"\1",g
    s,^Icon Library Offset:\s*\(.*\),-j\n\1,g
    s,^Icon Library:\s*\(.*\),-i\n\"\1\",g
    s,^Working Directory:\s*\(.*\),-w\n"\1",g
    s,^Show Command:\s*\(.*\),-s\n"\1",g
    s,^Target:\s*\(.*\),"\1",g
    1 i\
readshortcut
'
}
