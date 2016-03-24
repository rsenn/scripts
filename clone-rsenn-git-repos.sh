#!/bin/sh

lf="
  "

for REPO in ${@:-Scripts sw-utils dirlist bsed}
do
(BRANCH=
	case "$REPO" in
		sw-utils) CMD="cd libswsh${lf}bash setup.sh build${lf}sudo bash setup.sh install --prefix=/usr" ;;
		Scripts) CMD="sudo make install${lf}bash cp-bash-scripts.bash${lf}sudo bash cp-bash-scripts.bash" ;;
		dirlist) CMD="make DEBUG=0${lf}sudo make DEBUG=0 install" ;;
		bsed) BRANCH="inplace"; CMD=" make${lf}sudo make install prefix=/usr" ;;
		shish) CMD="./autogen.sh${lf}./configure --prefix=/usr${lf}make${lf}sudo make install" ;;
	esac
		CMD="git fetch --all${lf}$CMD"
		CMD="cd $REPO${lf}$CMD"
		CMD="git clone ${BRANCH:+-b $BRANCH} --depth=1 https://github.com/rsenn/${REPO}.git${lf}$CMD"

		trap 'echo " (Result: $?)" 1>&2' EXIT
		echo -n "Executing: $CMD " 1>&2
		eval "(set -e; $CMD)" >"$REPO.log" 2>&1 
		)
done
