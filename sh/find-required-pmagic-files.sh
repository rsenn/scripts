#!/bin/bash
NL="
"


MYBASE=`basename "$0" .sh`
MYDIR=`dirname "$0"`

while :; do
case "$1" in
    -depth | -maxdepth | -mindepth | -amin | -anewer | -atime | -cmin | -cnewer | -ctime | -fstype | -gid | -group | -ilname | -iname | -inum | -iwholename | -iregex | -links | -lname | -mmin | -mtime | -name | -newer | -path | -perm | -regex | -wholename | -size | -type | -uid | -used | -user | -xtype | -context | -printf | -fprint0 | -fprint | -fls) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1$NL$2"; shift 2 ;;
    -print | -daystart | -follow | -regextype | -mount | -noleaf | -xdev | -ignore_readdir_race | -noignore_readdir_race | -empty | -false | -nouser | -nogroup | -readable | -writable | -executable | -true | -delete | -print0 | -ls | -prune | -quit) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1"; shift ;;
  -i | --invert*) INVERT=true; shift ;;
  -P | --no*pkgs*) NO_PKGS=true; shift ;;
  *) break ;;
  esac
  done
  
[ "$INVERT" = true ] && NOT="-v"

cd "$MYDIR"

[ "$NO_PKGS" != true ]  && PKG_EXPR="pmodules/[^/]*\.t.z\$|pmodules/z[^/]*\.xz\$"
EXPR="(^bzImage|initramfs[^/]*\$|initrd[^/]*\$|initrd[^.]*\.img|pmodules/[^/]*\.SQFS\${PKG_EXPR:+|$PKG_EXPR})"

(
  find . -type f
) |
${SED-sed} -u 's,^\./,,' | ${GREP-grep -a --line-buffered --color=auto} -i -E $NOT "$EXPR" |
sort -u
