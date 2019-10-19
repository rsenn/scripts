git-remove-from-history () 
{ 
    git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch '$1'"
}
