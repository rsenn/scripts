# Configure BASH to append (rather than overwrite the history):
shopt -s histappend

# Attempt to save all lines of a multiple-line command in the same entry
shopt -s cmdhist

# After each command, append to the history file and reread it
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$"\n"}history -a; history -c; history -r"




export HISTFILE=$HOME/.bash_history
[ -f "$HISTFILE" -a ! -s "$HISTFILE" ] && history -r ~/.history
export HISTSIZE=16384
export HISTFILESIZE=-1

# Do not store a duplicate of the last entered command
HISTCONTROL=ignoredups




#history -w

