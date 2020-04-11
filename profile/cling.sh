: ${CLING_BINDIR=$(ls -d /opt/cling*/bin | sort -fuV |tail -n1)}

PATH="$PATH:$CLING_BINDIR"
