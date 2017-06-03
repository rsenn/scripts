pdfpages () 
{ 
    while [ $# -gt 0 ]; do
        pdfinfo "$1" | info_get Pages | addprefix "$1: ";
        shift;
    done
}
