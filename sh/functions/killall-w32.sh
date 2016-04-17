killall-w32()
{
  NL="
"
    ( IFS="
   ";
    PIDS=$(IFS="|"; ps.exe -aW |${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -i -E "($*)" | awk '{ print $1 }');
    kill.exe -f $PIDS )
}
