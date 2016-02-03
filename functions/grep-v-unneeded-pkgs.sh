grep-v-unneeded-pkgs()
{
 (set -- common data debuginfo devel doc docs el examples fonts javadoc plugin static theme tests extras demo manual test  help info support demos

 ${GREP-grep} -v -E "\-$(grep-e-expr "$@")(\$|\\s)")
}
