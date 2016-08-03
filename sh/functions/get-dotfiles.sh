get-dotfiles()
{
    ( UA="curl/7.25.0 (x86_64-suse-linux-gnu) libcurl/7.25.0 OpenSSL/1.0.1c zlib/1.2.7 libidn/1.25 libssh2/1.4.0";
    list-dotfiles "$@" | while read -r URL; do
        NAME=${URL##*/};
        USER=${URL%"/$NAME"};
        USER=${USER##*/};
        USER=${USER#"~"};
        ( set -x;
        wget -U "$UA" -O "${NAME#.}-$USER" "$URL" );
    done )
}
