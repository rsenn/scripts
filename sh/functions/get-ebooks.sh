get-ebooks () 
{ 
    export DATABASE=$(cygpath -am "$USERPROFILE/AppData/Roaming/Locate32/files.dbs");
    ls $LS_ARGS -td -- $( (locate32.sh  -E{pdf,epub,mobi,azw3,djv,djvu}|grep -i -E '(books|calibre)'; find-media.sh  -E{pdf,epub,mobi,azw3,djv,djvu} calibre books) |sort -f -u )
}
