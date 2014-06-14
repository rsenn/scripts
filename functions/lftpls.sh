lftpls()
{
    ( lftp "$1" -e "find $1/; exit" )
}
