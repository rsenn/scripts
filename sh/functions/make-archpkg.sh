make_archpkg() {
    for ARG; do     
      (cd "$ARG"
      NAME=${PWD##*/}; NAME=${NAME%.pkg*}; NAME=${NAME%.tar*}
      set -x
      ${TAR:-tar} \
        --dereference \
        --recursion \
        --numeric-owner --owner=0 \
        --no-acls  --no-xattrs --posix \
        --exclude={"*.tmp","*~","*.rej","*.orig",".*.swp"} \
        -cvJf ../"$NAME.pkg.tar.xz"  .[[:upper:]]*  [!.]*); done
 }

