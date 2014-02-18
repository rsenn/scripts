_msyspath()
{
 (add_to_script() { while [ "$1" ]; do SCRIPT="${SCRIPT:+$SCRIPT ;; }$1"; shift; done; }
 
  case $MODE in
    win*|mix*) #add_to_script "s|^${SYSDRIVE}[\\\\/]\(.\)[\\\\/]|\1:/|" "s|^${SYSDRIVE}[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
      add_to_script "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\\([\\\\/]\\)\\([^\\\\/]\\)\\?|\\1:\\2\\3|" ;;
  
    *) add_to_script "s|^\([A-Za-z0-9]\):|${SYSDRIVE}/\\1|" ;;
  esac
  case $MODE in
    win*|mix*)
       ROOT=$(mount | sed -n 's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      add_to_script "/^.:/!  s|^|$ROOT|"
    ;;
  esac
  case "$MODE" in
    win32) add_to_script "s|/|\\\\|g" ;;
    *) add_to_script "s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) add_to_script "s|^${SYSDRIVE}/A/|${SYSDRIVE}/a/|" "s|^${SYSDRIVE}/B/|${SYSDRIVE}/b/|" "s|^${SYSDRIVE}/C/|${SYSDRIVE}/c/|" "s|^${SYSDRIVE}/D/|${SYSDRIVE}/d/|" "s|^${SYSDRIVE}/E/|${SYSDRIVE}/e/|" "s|^${SYSDRIVE}/F/|${SYSDRIVE}/f/|" "s|^${SYSDRIVE}/G/|${SYSDRIVE}/g/|" "s|^${SYSDRIVE}/H/|${SYSDRIVE}/h/|" "s|^${SYSDRIVE}/I/|${SYSDRIVE}/i/|" "s|^${SYSDRIVE}/J/|${SYSDRIVE}/j/|" "s|^${SYSDRIVE}/K/|${SYSDRIVE}/k/|" "s|^${SYSDRIVE}/L/|${SYSDRIVE}/l/|" "s|^${SYSDRIVE}/M/|${SYSDRIVE}/m/|" "s|^${SYSDRIVE}/N/|${SYSDRIVE}/n/|" "s|^${SYSDRIVE}/O/|${SYSDRIVE}/o/|" "s|^${SYSDRIVE}/P/|${SYSDRIVE}/p/|" "s|^${SYSDRIVE}/Q/|${SYSDRIVE}/q/|" "s|^${SYSDRIVE}/R/|${SYSDRIVE}/r/|" "s|^${SYSDRIVE}/S/|${SYSDRIVE}/s/|" "s|^${SYSDRIVE}/T/|${SYSDRIVE}/t/|" "s|^${SYSDRIVE}/U/|${SYSDRIVE}/u/|" "s|^${SYSDRIVE}/V/|${SYSDRIVE}/v/|" "s|^${SYSDRIVE}/W/|${SYSDRIVE}/w/|" "s|^${SYSDRIVE}/X/|${SYSDRIVE}/x/|" "s|^${SYSDRIVE}/Y/|${SYSDRIVE}/y/|" "s|^${SYSDRIVE}/Z/|${SYSDRIVE}/z/|" 
    ;;
    win*)  add_to_script "s|^a:|A:|" "s|^b:|B:|" "s|^c:|C:|" "s|^d:|D:|" "s|^e:|E:|" "s|^f:|F:|" "s|^g:|G:|" "s|^h:|H:|" "s|^i:|I:|" "s|^j:|J:|" "s|^k:|K:|" "s|^l:|L:|" "s|^m:|M:|" "s|^n:|N:|" "s|^o:|O:|" "s|^p:|P:|" "s|^q:|Q:|" "s|^r:|R:|" "s|^s:|S:|" "s|^t:|T:|" "s|^u:|U:|" "s|^v:|V:|" "s|^w:|W:|" "s|^x:|X:|" "s|^y:|Y:|" "s|^z:|Z:|" ;;
  esac
  #echo "SCRIPT=$SCRIPT" 1>&2
 (sed "$SCRIPT" "$@")
 )
}
