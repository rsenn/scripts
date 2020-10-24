pdf-info() { 
 (. require.sh
  require info
  while [ $# -gt 0 ]; do
    pdfinfo "$1" | info_get "${FIELD}" | addprefix "$1: "
    shift
  done)
}

pdfpages() { FIELD=Pages pdf-info "$@"; }
pdftitle() { FIELD=Title pdf-info "$@"; }
