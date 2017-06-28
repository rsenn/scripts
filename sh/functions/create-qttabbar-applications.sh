chr2dec() {
    echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"%d\" \${ascii}]" | tclsh
}

create-win-kbd-shortcut() {
  N=0; for A; do case "$A" in
      "ALT" | "alt") N=$((N | 0x00140000)) ;;
      "CTRL" | "ctrl" | "CONTROL" | "control") N=$((N | 0x00120000)) ;;
      "SHIFT" | "shift") N=$((N | 0x00110000)) ;;
      ?) N=$(( N | $(chr2dec "$A") )) ;;
    esac; done; printf "%d" "$N"
    ([ "$DEBUG" = true ] && echo + create-win-kbd-shortcut "$@" "$(printf "(=0x%02x/%d)\n" "$N" "$N"))" 1>&2
 
 )
}

create-qttabbar-applications() { 
 ( : ${SPACE=" "}
   : ${BS="\\"}
   : ${NL="
"}; kbdcode=65
    tmpfile=$(mktemp)
   trap 'rm -f "$tmpfile"' EXIT
echo "REGEDIT4"
  echo
  echo '[HKEY_CURRENT_USER\Software\Quizo\QTTabBar\AppLauncher]'
  for file; do
    file=$(realpath "$file")
    fn=${file##*/}
    case "$file" in
      *.lnk)  winpath=$(cygpath -aw "$(readshortcut "$file")");name=$(basename "$file" .lnk); workdir=$(readshortcut -g "$file") ;;
      *) winpath=$(cygpath -aw "$file"); name=$(basename "${file%.*}"); name=${name##*Start};  workdir=${file%/*} ;;
    esac 
    case "$file" in
      Start?*.exe) arg="%C%" ;;
      *) arg="" ;;
    esac
     #workdir=$(cygpath -aw "$workdir")
     case "$workdir" in 
       *:) workdir="$workdir/" ;;
     esac
     workdir=${workdir//"/"/"\\\\"}
     if [ -n "$kbdcode" -a "$kbdcode" -gt 0 ]; then
       [ "$kbdcode" -eq 57 ] && kbdcode= key=0 ||   kbdcode=$((kbdcode+1))
       [ "$kbdcode" -gt 90 ] && kbdcode=49
     fi
     
     if [ -n "$kbdcode" -a "${kbdcode:-0}" -gt 0 ]; then
       winkbd=$(list SHIFT ALT $(asc2chr "$kbdcode"))
     else
       winkbd=
     fi
     

     [ -n "$winkbd" ] && key="$(create-win-kbd-shortcut $winkbd)" || key=0
     
     [ "$DEBUG" = true ] && echo "file='$file' name='$name' arg='$arg' kbdcode='$kbdcode' winkbd='${winkbd//$NL/$SPACE}' key='$key'" 1>&2
     
     echo -n -e "${winpath//$BS/$BS$BS}\x00${arg//$BS/$BS$BS}\x00${workdir//$BS/$BS$BS}\x00${key}\x00\x00\x00" >"$tmpfile"
     [ "$DEBUG" = true ] && sed "s,\\\\,\\\\\\\\,g; s,\\x00,|,g ; s|.*|regstr='&'\n|" "$tmpfile" 1>&2
     #hexdump -C <"$tmpfile" 1>&2
   (set -- $( hexdump -C <"$tmpfile" |
      sed '
        s,|.*,,
        s,^\s\+,,
        s,\s\+, ,g
        :lp
        N
        $! { b lp }
        s,[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]\+\s*,,g
        s,|[^\n]*\n,,g
        s,\s\+,\n,g
        p
      ' -n)
    echo "\"$name\"=hex(7):$(implode , <<<"$*")" 
   )
  done) | unix2dos
}
