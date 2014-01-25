PUTTY_sessions_key='HKCU\Software\SimonTatham\PuTTy\Sessions'

. reg-generic.sh

putty_session_list()
{
  reg_key_contains "$PUTTY_sessions_key"
}

putty_session_setcolors()
{
 (KEY="$PUTTY_sessions_key\\$1"

  if putty_session_exists "$1"; then
    reg_value_set "$KEY" "Colour0" "190,190,190" && # Default Foreground Color
    reg_value_set "$KEY" "Colour1" "255,255,255" && # Default Bold Foreground
    reg_value_set "$KEY" "Colour2" "0,0,0" && # Default Background Color
    reg_value_set "$KEY" "Colour3" "0,0,0" && # Default Bold Background
    reg_value_set "$KEY" "Colour4" "0,0,0" && # Cursor Text
    reg_value_set "$KEY" "Colour5" "190,190,190" && # Cursor Colour
    reg_value_set "$KEY" "Colour6" "0,0,0" && # ANSI Black
    reg_value_set "$KEY" "Colour7" "0,0,0" && # ANSI Black Bold
    reg_value_set "$KEY" "Colour8" "205,0,0" && # ANSI Red
    reg_value_set "$KEY" "Colour9" "255,0,0" && # ANSI Red Bold
    reg_value_set "$KEY" "Colour10" "0,205,0" && # ANSI Green
    reg_value_set "$KEY" "Colour11" "0,255,0" && # ANSI Green Bold
    reg_value_set "$KEY" "Colour12" "205,205,0" && # ANSI Yellow
    reg_value_set "$KEY" "Colour13" "255,255,0" && # ANSI Yellow Bold
    reg_value_set "$KEY" "Colour14" "0,0,205" && # ANSI Blue
    reg_value_set "$KEY" "Colour15" "0,0,255" && # ANSI Blue Bold
    reg_value_set "$KEY" "Colour16" "205,0,205" && # ANSI Magenta
    reg_value_set "$KEY" "Colour17" "255,0,255" && # ANSI Magenta Bold
    reg_value_set "$KEY" "Colour18" "0,205,205" && # ANSI Cyan
    reg_value_set "$KEY" "Colour19" "0,255,255" && # ANSI Cyan Bold
    reg_value_set "$KEY" "Colour20" "190,190,190" && # ANSI White
    reg_value_set "$KEY" "Colour21" "255,255,255"    # ANSI White Bold
  fi)
}

putty_session_exists()
{
  reg_key_exists "$KEY"
}
