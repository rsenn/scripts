multiply-resolution()
{ 
    ( WIDTH=${1%%x*};
    HEIGHT=${1#*x};
    echo $((WIDTH * $2))x$((HEIGHT * $2)) )
}
