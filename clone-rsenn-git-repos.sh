#!/bin/sh

IFS="
  "

for REPO in ${@:-Scripts sw-utils dirlist bsed}
do
(BRANCH=
	case "$REPO" in
		sw-utils) CMD="cd libswsh${IFS}bash setup.sh build${IFS}sudo bash setup.sh install --prefix=/usr" ;;
		Scripts) CMD="sudo make install${IFS}bash cp-bash-scripts.bash${IFS}sudo bash cp-bash-scripts.bash" ;;
		dirlist) CMD="make DEBUG=0${IFS}sudo make DEBUG=0 install" ;;
		bsed) BRANCH="inplace"; CMD=" make${IFS}sudo make install prefix=/usr" ;;
		shish) CMD="./autogen.sh${IFS}./configure --prefix=/usr${IFS}make${IFS}sudo make install" ;;
	esac
		CMD="git pull origin ${BRANCH:-master}${IFS}$CMD"
		CMD="git fetch --all${IFS}$CMD"
		CMD="cd $REPO${IFS}$CMD"
		CMD="git clone ${BRANCH:+-b $BRANCH} --depth=1 https://github.com/rsenn/${REPO}.git${IFS}$CMD"

		trap 'echo " (Result: $?)" 1>&2' EXIT
		echo -n "Executing: $CMD " 1>&2
		eval "(set -e; $CMD)" >"$REPO.log" 2>&1 
		)
done
