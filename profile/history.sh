HISTFILE=$HOME/.bash_history 
HISTSIZE=94208
HISTFILESIZE="48234496"
export HISTFILE HISTSIZE HISTFILESIZE

HISTCONTROL=ignoredups:erasedups
shopt -s histappend
#PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

