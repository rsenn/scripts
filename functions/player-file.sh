player-file()
{ 
  ( lsof -n $(pid-args "${@-mplayer}") 2> /dev/null 2> /dev/null 2> /dev/null 2> /dev/null | grep --color=auto --color=auto --color=auto ' REG ' | grep --color=auto --color=auto --color=auto -vE ' (mem|txt|DEL) ' | cut-lsof NAME |sed 's, ([^)]*)$,,' )
}
