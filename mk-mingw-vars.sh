#!/bin/sh

output_mingwvars() {
 (: ${O=${1:+$1/}mingwvars.cmd}
 echo "Outputting '$O'..." 1>&2
  cat <<EOF | unix2dos >"$O"
echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
rem cd "%~dp0"
EOF
)
}

output_mingwbuilds() {
 (: ${O=${1:+$1/}mingwbuilds.bat}
 echo "Outputting '$O'..." 1>&2
  cat <<EOF | unix2dos >"$O"
echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
rem echo %PATH%
rem cd "%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin"
cd "%~dp0"
cmd.exe
EOF
)
}

for DIR in "${@:-$PWD}"; do

  SUBDIR=$(find "$DIR" -iwholename "*bin/*gcc*" | sed "s|/bin.*||"|head -n1)

  SUBDIRNAME=${SUBDIR##*/}

  MINGWDIR=${SUBDIR%/$SUBDIRNAME*}

   output_mingwvars "$MINGWDIR"
   output_mingwbuilds "$MINGWDIR"
done

