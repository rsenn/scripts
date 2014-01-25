# /etc/sysprofile.d/prompt.sh
#
# Provides an informational shell prompt
#
# TODO:
#   - More flexible prompt composition
#   - 256 color terminal support
#

# ---------------------------------------------------------------------------
prompt_tone=33 

# ---------------------------------------------------------------------------
if test -z "$prompt_tone"; then
  prompt_tone=`hostname`
  prompt_tone=${prompt_tone%%.*}
  prompt_tone=${prompt_tone##*[a-z]}
  prompt_tone=`expr "$prompt_tone" - 1`
  prompt_tone=`expr "$prompt_tone" % 6`
  prompt_tone=`expr "$prompt_tone" + 31`
fi

# Color code shortcuts
# ---------------------------------------------------------------------------
prompt_hilite="\\[\\e[0;${prompt_tone}m\\]"
prompt_bold="\\[\\e[37;1m\\]"
prompt_nocolor="\\[\\e[0m\\]"

# Compose the prompt from the escape sequences
# ---------------------------------------------------------------------------
if test "`id -u`" = 0; then
  PS1="$prompt_hilite\\h$prompt_bold<$prompt_nocolor\\w$prompt_bold>$prompt_nocolor \\\$ "
else
  PS1="$prompt_nocolor\\u$prompt_hilite@$prompt_nocolor\\h$prompt_hilite<$prompt_nocolor\\w$prompt_hilite>$prompt_nocolor \\\$ "
fi

export PS1

# Discard the variables used
# ---------------------------------------------------------------------------
unset -v prompt_hilite prompt_bold prompt_nocolor prompt_tone
