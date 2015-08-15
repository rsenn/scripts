compare-dirs()
{
     diff -ru "$@" | sed -n \
         -e "/^Binary files/ s,^Binary files \(.*\) and \(.*\) differ,\1 \2,p" \
         -e "s,^Only in \(.*\): \(.*\),\1/\2,p" \
         -e "/^diff/ { N; /\n---/ { N; /\n+++/ { s,\n.*,, ;; s,^diff\s\+,, ;; s,^-[^ ]* ,,g ;; p } } }"
}
