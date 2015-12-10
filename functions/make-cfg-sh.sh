make-cfg-sh() { 
 (for ARG in "${@:-./configure}"; do
    HELP=$("$ARG" --help=recursive ); ( echo "$HELP" | grep --color=auto --line-buffered -q '^\s*--.*dir' ) || HELP=$( ("$ARG" --help ; echo "$HELP") |sort -t- -k2 -n -u ); ( echo "$HELP" | grep --color=auto --line-buffered -q '^\s*--' ) || HELP=$("$ARG" --help ); { 
      unset O; while read -r LINE; do
          case "$LINE" in 
              *--enable-[[:upper:]]* | *--with-[[:upper:]]* | *--without-[[:upper:]]* | *--disable-[[:upper:]]*)
                  continue
              ;;
              *\(*--*)
                  continue
              ;;
              *--enable* | *--disable* | *--with* | *--*dir*=*)
                  LINE=${LINE#*--}
              ;;
              *)
                  continue
              ;;
          esac
          LINE=${LINE%%" "*}; LINE=${LINE%%[\',]*}; BRACKET=false
          case "$LINE" in 
              *\[*\]*)
                  LINE=${LINE/"["/}; LINE=${LINE/"]"/}; BRACKET=TRUE
              ;;
          esac
          case "$LINE" in 
              *=*)
                  OPT=${LINE%%=*}; VALUE=${LINE#*=}
              ;;
              *)
                  OPT="$LINE"
              ;;
          esac
          case "$OPT" in 
              *)

              ;;
          esac
          VAR=$(tr [[:upper:]] [[:lower:]] <<<"${OPT//"-"/"_"}"); WHAT= DEFAULT=
          case "$OPT" in 
              with* | without*)
                  WHAT=${VAR%%[-_]*}; VAR=${VAR#*_}
              ;;
              enable* | disable*)
                  WHAT=${VAR%%[-_]*}; #VAR=${VAR#*_}; VALUE=
          case "$WHAT" in 
                      enable)
                          DEFAULT=""
                      ;;
                      disable)
                          DEFAULT="true"
                      ;;
                  esac
              ;;
              *dir*)
                  WHAT=dir; VALUE=; ;;
              prefix)
                  WHAT=; VALUE=
              ;;
          esac
          VAR=${VAR%" "}
          case "$VAR" in 
              build | target)
                  SUBST=\"\${$VAR:-\$host}\"
              ;;
              includedir | libdir | libexecdir | bindir | sbindir)
                  VALUE=\$prefix/${VAR%dir}; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              sysconfdir)
                  VALUE=\$prefix/etc; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              localstatedir)
                  VALUE=\$prefix/var; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              infodir | mandir | docdir | localedir)
                  VALUE=\$prefix/share/${VAR%dir}; SUBST=\"\${$VAR:-$VALUE}\"
              ;;
              *dir)
                  continue
              ;;
              *)
                  SUBST=\"\${$VAR}\"
              ;;
          esac
          case "$DEFAULT" in 
              "")

              ;;
              *)
                  pushv-unique V ": \${$VAR=\"$DEFAULT\"}"
              ;;
          esac
          case "$WHAT" in 
              *able| with | "")
                case "$WHAT"  in
                  *able) unset SUBST 
                  #[ "$WHAT" = enable ] && unset WHAT 
                  ;;
                esac

                  [ "$WHAT" = enable ] &&  VAR=${VAR#*[-_]}
                  pushv-unique O "  ${VAR:+\${$VAR:+--${WHAT:+$WHAT-}${OPT#*-}${SUBST:+=$SUBST}}} \\"
              ;;
              *)
                  pushv-unique O "  --$OPT${VALUE:+=$SUBST} \\"
              ;;
          esac
      done; echo "$V

$ARG \\
$O
"'  "$@"'
      } <<< "$HELP"; done )
}
