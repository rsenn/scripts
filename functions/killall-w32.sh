killall-w32()
{
    ( IFS="
	 ";
    PIDS=$(IFS="|"; ps.exe -aW |grep -i -E "($*)" | awk '{ print $1 }');
    kill.exe -f $PIDS )
}
