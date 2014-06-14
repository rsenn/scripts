pid-args()
{
  pid-of "$@" | sed -n  "/^[0-9]\+$/ s,^,-p\n,p"
}
