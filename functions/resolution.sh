resolution()
{ 
    ( WIDTH=${1%%${MULT_CHAR-x}*};
    HEIGHT=${1#*${MULT_CHAR-x}};
    echo $((WIDTH / $2))${MULT_CHAR-x}$((HEIGHT / $2)) )
}
