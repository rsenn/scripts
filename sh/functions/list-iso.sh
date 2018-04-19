list-iso() {
 (for ISO; do
    isoinfo -R -l -i "$ISO" |
    decode-ls-lR.sh | sed -u "s|^/||"
  done)
}
