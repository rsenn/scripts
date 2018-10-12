alias s='sudo'
alias si='sudo -i'

alias schr='sudo chown `id -u`:`id -g`'
alias schR='sudo chown -R `id -u`:`id -g`'

alias df='df -T -x tmpfs -x rootfs'
alias astyle='astyle --style=attach --indent=spaces=2 --unpad-paren --pad-oper --keep-one-line-{blocks,statements}'

alias xargs='xargs -d "\\n"'
alias grepdiff='grepdiff --output-matching=hunk'

alias curl='curl -L -k'
alias wget='wget --content-disposition --no-check-certificate --no-use-server-timestamps'

alias lynx='lynx -accept_all_cookies -cookies'

alias tar='tar -m '
alias cols='column -c $(tput cols)'

alias aria2='aria2c --file-allocation=none'

alias grpe=grep
alias gpre=grep
alias grep='grep --line-buffered --color=auto'
alias ls='ls --color=auto'
alias sed='sed -u'
alias aria2c='aria2c --file-allocation=none'
alias rsync='rsync --times --noatime'
alias rsync='rsync --times --noatime'
alias xclip='xclip -selection clipboard'

alias aria2c='aria2c --file-allocation=none'
alias astyle='astyle --style=attach --indent=spaces=2 --unpad-paren --pad-oper --keep-one-line-{blocks,statements}'
alias cols='column -c $(tput cols)'
alias cproto='cproto -D__{x,y,value}='
alias curl='curl -L -k'
alias df='df -T -x tmpfs -x rootfs'
alias dnf='dnf -y'
alias gpre=grep
alias grep='grep --line-buffered --color=auto'
alias grepdiff='grepdiff --output-matching=hunk'
alias grpe=grep
alias ls='ls --color=auto'
alias lynx='lynx -accept_all_cookies -cookies'
alias rsync='rsync --times --noatime'
alias rsync='rsync --times'
alias s='sudo'
alias schR='sudo chown -R `id -u`:`id -g`'
alias schr='sudo chown `id -u`:`id -g`'
alias sed='sed -u'
alias si='sudo -i'
alias tar='tar -m --keep-directory-symlink'
alias tar='tar -m --no-recursion'
alias wget='wget --content-disposition --no-check-certificate --no-use-server-timestamps'
alias xargs='xargs -d "\\n"'
alias xclip='xclip -selection clipboard'

alias vncviewer='vncviewer -depth 16 -compresslevel 8 -quality 6   -x11cursor'
