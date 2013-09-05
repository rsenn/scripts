convert-boot-entries()
{
  ([ -z "$FORMAT" ] && FORMAT="$1"
  	
    for FILE; do
      convert-boot-file "$FILE" "$FORMAT"
    done
  )
}