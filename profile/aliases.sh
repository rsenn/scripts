alias aria2='aria2c --file-allocation=none'
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
alias sed='sed -u'
alias tar='tar -m'
alias vncviewer='vncviewer -depth 16 -compresslevel 8 -quality 6   -x11cursor'
alias wget='wget --content-disposition --no-check-certificate --no-use-server-timestamps'
alias xargs='xargs -d "\\n"'
alias xclip='xclip -selection clipboard'
if type sudo 2>/dev/null >/dev/null; then
  alias s='sudo'
  alias schR='sudo chown -R `id -u`:`id -g`'
  alias schr='sudo chown `id -u`:`id -g`'
  alias si='sudo -i'
else
  alias schR='chown -R `id -u`:`id -g`'
  alias schr='chown `id -u`:`id -g`'
fi
alias qemu-system-x86_64='qemu-system-x86_64 -enable-kvm -machine q35,accel=kvm -device intel-iommu -cpu host -netdev user,id=network0 -device rtl8139'

alias prettier-eslint='prettier-eslint --write --semi --bracket-spacing'
