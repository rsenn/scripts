yaourt-cutver() {
 (NAME='\([^ \t/]\+\)'
 sed "s|^${NAME}/${NAME}\s\+\([^ \t]\+\)\s\+\(.*\)|\1/\2 \4|")
}
