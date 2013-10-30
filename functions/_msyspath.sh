_msyspath()
{
 (case $MODE in
    win32|mixed) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
    *) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^\([A-Za-z0-9]\):|/\\1|" ;;
  esac
  case $MODE in
    win32) 
      SCRIPT="${SCRIPT:+$SCRIPT ;; }s|/|\\\\|g"
      ROOT=$(mount  |sed -n  's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      SCRIPT="${SCRIPT:+$SCRIPT ;; }/^.:/!  s|^|$ROOT|"

      
      ;;
    *) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^/A/|/a/|;;s|^/B/|/b/|;;s|^/C/|/c/|;;s|^/D/|/d/|;;s|^/E/|/e/|;;s|^/F/|/f/|;;s|^/G/|/g/|;;s|^/H/|/h/|;;s|^/I/|/i/|;;s|^/J/|/j/|;;s|^/K/|/k/|;;s|^/L/|/l/|;;s|^/M/|/m/|;;s|^/N/|/n/|;;s|^/O/|/o/|;;s|^/P/|/p/|;;s|^/Q/|/q/|;;s|^/R/|/r/|;;s|^/S/|/s/|;;s|^/T/|/t/|;;s|^/U/|/u/|;;s|^/V/|/v/|;;s|^/W/|/w/|;;s|^/X/|/x/|;;s|^/Y/|/y/|;;s|^/Z/|/z/|" ;; 
    win*)  SCRIPT="${SCRIPT:+$SCRIPT ;; }s|^a:|A:|;;s|^b:|B:|;;s|^c:|C:|;;s|^d:|D:|;;s|^e:|E:|;;s|^f:|F:|;;s|^g:|G:|;;s|^h:|H:|;;s|^i:|I:|;;s|^j:|J:|;;s|^k:|K:|;;s|^l:|L:|;;s|^m:|M:|;;s|^n:|N:|;;s|^o:|O:|;;s|^p:|P:|;;s|^q:|Q:|;;s|^r:|R:|;;s|^s:|S:|;;s|^t:|T:|;;s|^u:|U:|;;s|^v:|V:|;;s|^w:|W:|;;s|^x:|X:|;;s|^y:|Y:|;;s|^z:|Z:|" ;;
    esac
  (#set -x; 
   sed -u "$SCRIPT" "$@")
   )
 
 
 
}
