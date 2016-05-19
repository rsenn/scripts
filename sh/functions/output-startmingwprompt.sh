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
