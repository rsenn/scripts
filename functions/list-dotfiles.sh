list-dotfiles()
{
    ( for ARG in "$@";
    do
        dlynx.sh "http://dotfiles.org/.${ARG#.}" | grep --color=auto --color=auto --color=auto --color=auto "/.${ARG#.}\$";
    done )
}
