grep-v-unneeded-pkgs()
{
 (set -- common data debuginfo devel doc docs el examples fonts javadoc plugin static theme tests extras demo manual test  \
	 help info support demos bzr svn git hg

 ${GREP-grep
-a
--line-buffered
--color=auto} -v -E "\-$(grep-e-expr "$@")(\$|\\s)")
}
