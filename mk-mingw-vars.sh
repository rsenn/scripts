#!/bin/sh
BS='\'
FS='/'

output_mingwvars() {
 (: ${O=${1:+$1/}mingwvars.cmd}
 echo "Outputting '${O//$FS/$BS}'..." 1>&2
  cat <<EOF | unix2dos >"$O"
@echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
if "%1" == "" goto end
cd "%1"
:end
echo Variables are set up for "${SUBDIRNAME}"
EOF
)
}

output_startmingwprompt() {
 (: ${O=${1:+$1/}start-mingw-prompt.bat}
 echo "Outputting '${O//$FS/$BS}'..." 1>&2
  cat <<EOF | unix2dos >"$O"
@echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
rem echo %PATH%
rem cd "%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin"
cd "%~dp0"
if "%1" == "" goto end
cd "%1"
:end
cmd.exe /k "call %~dp0mingwvars.cmd"
EOF
)
}

for DIR in "${@:-$PWD}"; do

  SUBDIR=$(find "$DIR" -iwholename "*bin/*gcc*" | sed "s|/bin.*||"|head -n1)

  SUBDIRNAME=${SUBDIR##*/}

  MINGWDIR=${SUBDIR%/$SUBDIRNAME*}

   output_mingwvars "$MINGWDIR"
   output_startmingwprompt "$MINGWDIR"
done

