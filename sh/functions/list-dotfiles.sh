list-dotfiles()
{
    ( for ARG in "$@";
    do
        dlynx.sh "http://dotfiles.org/.${ARG#.}" | ${GREP-grep} "/.${ARG#.}\$";
    done )
}
