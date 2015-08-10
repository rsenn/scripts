list-deb() 
{ 
  (for ARG in "$@";
  do
    (trap 'rm -rf "$TMPDIR"' EXIT QUIT TERM INT;
    TMPDIR=$(mktemp -d);
    mkdir -p "$TMPDIR";
    ABSPATH=$(realpath "$ARG");
    cd "$TMPDIR";
    ar x "$ABSPATH";
    set -- data.*;
    tar -tf "$1" | removeprefix ./ | /bin/grep --color=auto --line-buffered -v '^\s*$');
  done)
}
