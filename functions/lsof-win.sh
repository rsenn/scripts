lsof-win()
{
  (for PID in $(ps -aW | sed 1d |awkp 1); do
    handle -p "$PID" |sed "1d;2d;3d;4d;5d; s|^|$PID\\t|"
  done)
}