grep-v-optpkgs()
{
    grep --color=auto -v -E '\-(doc|dev|dbg|extra|lite|prof|extra|manual|data|examples|source|theme|manual|demo|help|artwork|contrib)'
}
