#!/bin/sh
BS='\'
FS='/'

output-mingwvars() {
 (: ${O=${1:+$1/}mingwvars.cmd}
 echo "Outputting '${O//$FS/$BS}'..." 1>&2
 case "$O" in
   *.cmd | *.bat) 
	cat <<EOF | unix2dos >"$O"
@echo off
set PATH=%~dp0${SUBDIRNAME};%~dp0${SUBDIRNAME}\bin;%PATH%
if "%1" == "" goto end
cd "%1"
:end
echo Variables are set up for "${SUBDIRNAME}"
EOF
     ;;
   *.sh | *.bash)
     cat <<EOF >"$O"
#!/bin/sh
PATH="\${_}${SUBDIRNAME}:\${_}${SUBDIRNAME}/bin:\$PATH"
echo "Variables are set up for ${SUBDIRNAME}" 1>&2
EOF
    ;;
  esac
)
}

output-startmingwprompt() {
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

  SUBDIR=$(find "$DIR" -iwholename "*bin/*gcc*" | ${SED-sed} "s|/bin.*||"|head -n1)

  SUBDIRNAME=${SUBDIR##*/}

  MINGWDIR=${SUBDIR%/$SUBDIRNAME*}

   O="$MINGWDIR/mingwvars.sh" output-mingwvars "$MINGWDIR"
   output-startmingwprompt "$MINGWDIR"
done

