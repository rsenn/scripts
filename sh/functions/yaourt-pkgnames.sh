yaourt-pkgnames() {
 (NAME='\([^ \t/]\+\)'
 ${SED-sed} -n "s|^${NAME}/${NAME}\s\+\(.*\)|\2|p")
}
