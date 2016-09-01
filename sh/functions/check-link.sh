check-link()
{
  (TARGET=$(readshortcut "$1")
    test -e "$TARGET")
}
