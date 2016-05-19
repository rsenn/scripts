killall-w32()
{
    ( IFS="
   ";
    PIDS=$(IFS="|"; ps.exe -aW |${GREP-grep -a --line-buffered --color=auto} -i -E "($*)" | awk '{ print $1 }');
    kill.exe -f $PIDS )
}
