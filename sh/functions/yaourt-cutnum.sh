yaourt-cutnum() {
 #(NAME='\([^ \t/]\+\)';  ${SED-sed} "s|^${NAME}/${NAME}\s\+\(.*\)\s\+\(([0-9]\+)\)\(.*\)|\1/\2 \3 \5|")
 ${SED-sed} "s|\s\+\(([0-9]\+)\)\(.*\)| \2|"
}