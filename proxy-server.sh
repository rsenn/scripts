PROXY_key='HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
PROXY_value='ProxyServer'

proxy_get()
{
   reg query "$PROXY_key" /v "$PROXY_value" |
   sed -n "s/.*ProxyServer.*REG_SZ\s*\(.*\)/\1/p"
}

proxy_delete()
{
  reg delete "$PROXY_key" /v "$PROXY_value"
}

proxy_add()
{
  reg add "$PROXY_key" /v "$PROXY_value" /t REG_SZ /d "$*"
}

proxy_set()
{
  (yes Y | proxy_delete) 2>/dev/null >/dev/null &&
  proxy_add "$@"
}
