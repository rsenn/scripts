dl-slackpkg()
{
  (: ${DIR=/tmp}
   for PKG; do
     BASE=${PKG##*/}
   
wget -P "$DIR" -c "$PKG" && installpkg "$DIR/$BASE"|| break
  done)
}
