compare-dirs()
{
     diff -ru "$@" | ${SED-sed} -n \
         -e "/^Binary files/ s,^Binary files \(.*\) and \(.*\) differ, ,p" \
         -e "s,^Only in \(.*\): \(.*\),/,p" \
         -e "/^diff/ { N; /---/ { N; /+++/ { s,.*,, ; s,^diff\s\+,, ; s,^-[^ ]* ,,g ; p } } }"
}
