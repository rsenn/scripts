reg_query()
{
  reg query "$@"
}

reg_key_exists()
{
  reg query "$@" 2>/dev/null >/dev/null
}

reg_key_contains()
{
 (PATTERN=`echo "$*" | sed -e 's,\\\\,\\\\\\\\,g' -e 's,^HKCU,HKEY_CURRENT_USER,'`

  reg query "$*" 2>/dev/null | sed -n "s/^$PATTERN\\\\//p")
}

reg_value_exists()
{
  reg query "$1" /v "$2" 2>/dev/null >/dev/null
}

reg_value_remove()
{
  (yes "Y" | reg delete "$1" /v "$2") >/dev/null
}

reg_value_set()
{
 (KEY="$1" VALUE="$2"
  shift 2
  reg_value_remove "$KEY" "$VALUE"
  reg add "$KEY" /v "$VALUE" /d "$*") >/dev/null
}
