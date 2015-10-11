cleanup-desktop() {
 (mv -vf -- "$DESKTOP"/../../*/Desktop/* "$DESKTOP"
  cd "$DESKTOP"
  links=$( ls -ltdr --time-style=+%Y%m%d -- *.lnk|grep "$(date +%Y%m%d|removesuffix '[0-9]')"|cut-ls-l )
  set  -- $( ls -td -- $(ls-files|grep -viE '(\.lnk$|\.ini$)'))
  touch "$@"
  mv -vft "$DOCUMENTS" -- "$@" *" - Shortcut"*
  d=$(ls -d  ../Unused* )

  for l in $links; do
    while :; do
      read -r -p "Move ${l##*/} to $d? " ANS
			case "$ANS" in
				y*|j*|Y*|J*) mv -vi -t -- "$l" ;;
				n*|N*) ;;
				*) continue ;;
			esac
			break
    done

  done
  )
}
