pdfpextr()
{
(FIRST=$(($1)) LAST=$(($2))
    # this function uses 3 arguments:
    #     $1 is the first page of the range to extract
    #     $2 is the last page of the range to extract
    #     $3 is the input file
    #     output file will be named "inputfile_pXX-pYY.pdf"
    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage="$FIRST" \
       -dLastPage="$LAST" \
       -sOutputFile=${3%.[Pp][Dd][Ff]}_p"$FIRST"-p"$LAST".pdf \
       "${3}"
}
