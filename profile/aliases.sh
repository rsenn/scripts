alias aria2='aria2c --file-allocation=none'
alias aria2c='aria2c --file-allocation=none'
alias astyle='astyle --style=attach --indent=spaces=2 --unpad-paren --pad-oper --keep-one-line-{blocks,statements}'
[ "`type -t cols`" = "" ] || { unset -f cols >&/dev/null; unalias cols >&/dev/null; alias cols='column -c $(tput cols)'; }
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
alias tightvnc='xtightvncviewer -depth 16 -compresslevel 8 -quality 6   -x11cursor'
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

alias prettier='prettier --trailing-comma none --write  --print-width 200 --semi --bracket-spacing --no-insert-pragma'
alias prettier-eslint='prettier-eslint --trailing-comma none --write  --print-width 200 --semi --bracket-spacing --no-insert-pragma'
alias jtags='ctags -R --exclude=node_modules --exclude=.next && sed -i -E "/^(if|switch|function|module\.exports|it|describe).+language:js$/d; /\.lua/d" tags'
alias touch='touch --time=mtime'
alias arduino-builder='arduino-builder -compile -hardware /opt/arduino-1.8.12/hardware -tools /opt/arduino-1.8.12/tools-builder -tools /opt/arduino-1.8.12/hardware/tools/avr -built-in-libraries /opt/arduino-1.8.12/libraries -libraries ~/Arduino/libraries '
alias lsof='lsof -w'
alias sublime_text='LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 sublime_text'
