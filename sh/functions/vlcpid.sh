vlcpid()
{
  NL="
"
    ( ps -aW | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -i vlc.exe | awkp )
}
