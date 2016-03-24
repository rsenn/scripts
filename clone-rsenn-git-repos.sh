#!/bin/sh

NL="
  "

for REPO in ${@:-Scripts sw-utils dirlist bsed}
do
(BRANCH=
	case "$REPO" in
		sw-utils) CMD="cd libswsh${NL}bash setup.sh build${NL}sudo bash setup.sh install --prefix=/usr" ;;
		Scripts) CMD="sudo make install${NL}bash cp-bash-scripts.bash${NL}sudo bash cp-bash-scripts.bash" ;;
		dirlist) CMD="make DEBUG=0${NL}sudo make DEBUG=0 install" ;;
		bsed) BRANCH="inplace"; CMD=" make${NL}sudo make install prefix=/usr" ;;
		shish) CMD="./autogen.sh${NL}./configure --prefix=/usr${NL}make${NL}sudo make install" ;;
	esac
		CMD="git fetch --all${NL}$CMD"
		CMD="cd $REPO${NL}$CMD"
		CMD="git clone ${BRANCH:+-b $BRANCH} --depth=1 https://github.com/rsenn/${REPO}.git${NL}$CMD"

		trap 'echo " (Result: $?)" 1>&2' EXIT
		echo -n "Executing: $CMD " 1>&2
		eval "(set -e; $CMD)" >"$REPO.log" 2>&1 
		)
done
