yaourt-cutver() {
 (NAME='\([^ \t/]\+\)'
 ${SED-sed} "s|^${NAME}/${NAME}\s\+\([^ \t]\+\)\s\+\(.*\)|\1/\2 \4|")
}
