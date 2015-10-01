output_mingwvars() {
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
