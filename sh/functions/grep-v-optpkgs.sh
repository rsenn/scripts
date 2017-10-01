grep-v-optpkgs()
{
    ${GREP-grep} -v -E '\-(doc|dev|dbg|extra|lite|prof|extra|manual|data|examples|source|theme|manual|demo|help|artwork|contrib|svn$|bzr$|hg$|git$|cvs$)'
}
