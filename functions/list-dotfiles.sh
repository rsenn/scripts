list-dotfiles()
{
    ( for ARG in "$@";
    do
        dlynx.sh "http://dotfiles.org/.${ARG#.}" | ${GREP-grep} --color=auto --color=auto --color=auto --color=auto "/.${ARG#.}\$";
    done )
}
