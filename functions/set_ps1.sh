set_ps1()
{ 
    local b="\\[\\e[37;1m\\]" d="\\[\\e[0;38m\\]" g="\\[\\e[1;36m\\]" n="\\[\\e[0m\\]";
    export PS1="$n\\u$g@$n\\h$g<$n\\w$g>$n \\\$ "
}
