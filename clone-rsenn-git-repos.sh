#!/bin/sh

IFS="
  "

while :; do
  case "$1" in
    -c | --clean) CLEAN=true; shift ;;
    -f | --force) FORCE=true; shift ;;
    *) break ;;
  esac
done

for REPO in ${@:-Scripts sw-utils dirlist bsed}
do
 (BRANCH= CMD=
  case "$REPO" in
    sw-utils) CMD="cd libswsh${IFS}bash setup.sh build${IFS}sudo bash setup.sh install --prefix=/usr" ;;
    Scripts) CMD="sudo make install${IFS}sh cp-bash-scripts.sh${IFS}sudo sh cp-bash-scripts.sh" ;;
    dirlist) CMD="make DEBUG=0${IFS}sudo make DEBUG=0 install" ;;
    bsed) BRANCH="inplace"; CMD=" make${IFS}sudo make install prefix=/usr" ;;
    shish) CMD="./autogen.sh${IFS}./configure --prefix=/usr${IFS}make${IFS}sudo make install" ;;
  esac
	CMD="${IFS%?}(cd $REPO${IFS}$CMD)"
	[ "$FORCE" = true ] && CMD="||${IFS}(cd $REPO; git fetch --all; git reset --hard; git pull origin ${BRANCH:-master})$CMD"
	CMD="git clone ${BRANCH:+-b $BRANCH} --depth=1 https://github.com/rsenn/${REPO}.git $CMD"
  [ "$CLEAN" = true ] && CMD="rm -rf $REPO/${IFS}$CMD"

	trap 'R=$?; echo " (Result: $R)" 1>&2; [ $R = 0 ] && rm -vf "$REPO.log" || { echo "Output: "; cat "$REPO.log"; } 1>&2' EXIT
	echo -n "Executing:${IFS}$CMD " 1>&2
	eval "(set -e; $CMD)" >"$REPO.log" 2>&1)
done
