yum-joinlines () 
{ 
    ${SED-sed} '/^[^ ]/ { :lp; N; /\n\s.*:\s/ { s,\n\s\+:\s*, , ; b lp };  :lp2; /\n/ { P; D; b  lp2; } }' "$@"
}
