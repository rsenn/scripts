gen-desktop () 
{ 
    cat  > "$(basename "$1")".desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=${1##*/}
GenericName=${1##*/}
Comment=
Icon=${1##*/}
Type=Application
Categories=Application;
Exec=$1
Terminal=false
Path=
StartupNotify=true

EOF

}
