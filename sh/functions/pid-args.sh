pid-args()
{
  pid-of "$@" | ${SED-sed} -n  "/^[0-9]\+$/ s,^,-p\n,p"
}
