volname () 
{ 
    drive=$(cygpath -m "$1");
    cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p'
}
