vlcpid()
{
    ( ps -aW | ${GREP-grep
-a
--line-buffered
--color=auto} -i vlc.exe | awkp )
}
