shell-functions()
{ 
    ( . require.sh;
    require script;
    declare -f | script_fnlist )
}
