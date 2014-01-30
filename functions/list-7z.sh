list-7z() 
{ 
    7z l "$1" | cut-ls-l 4 | sed 's,^[0-9]\+\s\+,,' | grep --color=auto --line-buffered -E '(\\|^[A-Za-z]|^[^\\]*\.)' | sed '1d; $d; s,\\,/,g'
}
