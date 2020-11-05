pid-for-window() {
  (WM_PID=`xprop -id "$1" _NET_WM_PID`
   echo "${WM_PID#* = }")
}
