yaourt-pkgnames() {
 (NAME='\([^ \t/]\+\)'
 sed -n "s|^${NAME}/${NAME}\s\+\(.*\)|\2|p")
}
