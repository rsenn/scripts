addprefix()
{ 
    ( while read -r LINE; do
        echo "$1${LINE}";
    done )
}
