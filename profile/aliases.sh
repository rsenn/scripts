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

alias tar='tar -m --keep-directory-symlink'
alias cols='column -c $(tput cols)'

alias aria2='aria2c --file-allocation=none'

alias grpe=grep
alias gpre=grep
