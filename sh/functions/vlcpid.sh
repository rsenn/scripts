vlcpid()
{
    ( ps -aW | ${GREP-grep} -i vlc.exe | awkp )
}
