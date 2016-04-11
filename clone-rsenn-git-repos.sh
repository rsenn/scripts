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

if [ "${SUDO+set}" != set ]; then
  if [ "${UID-`id -u`}" = 0 -o -w /usr/bin ]; then
      SUDO=
  else
    type sudo 2>/dev/null 1>/dev/null && SUDO="sudo" || SUDO=false
  fi
fi

cleanup() {
	R=$1; echo " (Result: $R)" 1>&2; [ $R = 0 ] && rm -f "$REPO.log" || { echo "Output: "; cat "$REPO.log"; } 1>&2
}

for REPO in ${@:-Scripts sw-utils dirlist bsed}
do
 (BRANCH= CMD=
  case "$REPO" in
    sw-utils) CMD="cd libswsh${IFS}bash setup.sh build${IFS}${SUDO:+$SUDO }bash setup.sh install --prefix=/usr" ;;
    Scripts) CMD="${SUDO:+$SUDO }make install${IFS}sh cp-bash-scripts.sh${IFS}${SUDO:+$SUDO }sh cp-bash-scripts.sh" ;;
    dirlist) CMD="make DEBUG=0${IFS}${SUDO:+$SUDO }make DEBUG=0 install" ;;
    bsed) BRANCH="inplace"; CMD=" make${IFS}${SUDO:+$SUDO }make install prefix=/usr" ;;
    shish) CMD="./autogen.sh${IFS}./configure --prefix=/usr${IFS}make${IFS}${SUDO:+$SUDO }make install" ;;
  esac
	CMD="${IFS%?}(cd $REPO${IFS}$CMD)"
	[ "$FORCE" = true ] && CMD="||${IFS%?}(cd $REPO${IFS}git fetch --all${IFS}git reset --hard${IFS}git pull origin ${BRANCH:-master})$CMD"
	CMD="git clone ${BRANCH:+-b $BRANCH} --depth=1 https://github.com/rsenn/${REPO}.git $CMD"
  [ "$CLEAN" = true ] && CMD="rm -rf $REPO/${IFS}$CMD"

	trap  'cleanup $?' EXIT
	echo -n "Executing:${IFS}$CMD " 1>&2
	eval "(set -e; $CMD)" >"$REPO.log" 2>&1)
done
