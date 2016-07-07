for D in $(df -l|${SED-sed} 1d|sort -nk3| awk '{ print $1 }'); do echo "$D
cd \\
list-r64.exe >files.tmp
del /f files.list
move files.tmp files.list
"; done |unix2dos.exe  |tee c:/Temp/gen-list-index.cmd
