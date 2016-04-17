list-dotfiles()
{
  NL="
"
    ( for ARG in "$@";
    do
        dlynx.sh "http://dotfiles.org/.${ARG#.}" | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "/.${ARG#.}\$";
    done )
}
