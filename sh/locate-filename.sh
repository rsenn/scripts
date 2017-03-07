#!/bin/bash

: ${MYNAME=`basename "$0" .sh`}

archives_EXTS="rar zip 7z cab tar tar.Z tar.gz tar.xz tar.bz2 tar.lzma tgz txz tbz2 tlzma cpio"
audio_EXTS="mp3 mp2 m4a m4b wma rm ogg flac mpc wav aif aiff raw"
books_EXTS="pdf epub mobi azw3 djv djvu"
fonts_EXTS="otf ttf fon bdf pcf"
fonts_EXTS="ttf otf bdf pcf fon"
images_EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff png pnm"
music_EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff mod s3m xm it 669 mp4"
packages_EXTS="txz tgz rpm deb"
scripts_EXTS="sh py rb bat cmd"
software_EXTS="rar zip 7z tar.gz tar.xz tar.bz2 tgz txz tbz2 exe msi msu cab vbox-extpack apk deb rpm iso daa dmg run pkg app bin iso daa nrg dmg exe sh tar.Z tar.gz zip"
software_EXTS="$software_EXTS 7z app bin daa deb dmg exe iso msi msu cab vbox-extpack apk nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz zip"
sources_EXTS="c cc cpp cxx h hh hpp hxx mm java"
videos_EXTS="3gp avi f4v flv m4v m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"
vmdisk_EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"


addexts() {
eval "EXTS=\"\${EXTS:+\$EXTS }\${${1}_EXTS}\""
}
addext() {
eval "EXTS=\"\${EXTS:+\$EXTS }\${1}\""
}
addexts ${MYNAME#locate-}

locate_filenames()
{
    (IFS="
 "
   ANY=".*"
 while :; do
      case "$1" in
        -c | --class) addexts "$2"; shift  2 ;;
        -c=* | --class=*) addexts "${1#*=}"; shift ;;
        -c*) addexts "${1#-?}"; shift   ;;
                -E | ---ext) addext "$2"; shift  2 ;;
        -E=* | ---ext=*) addext "${1#*=}"; shift ;;
        -E*) addext "${1#-?}"; shift   ;;
    #    -c | --complete) PARTIAL_EXPR="" ; shift ;;
            -x | --debug) DEBUG=true; shift ;;
            -f | --filepart) ANY="[^/]*"; shift ;;
            *) break ;;
            esac
            done
 [ $# -le 0 ] && set -- ".*"
 for ARG; do ([ "$DEBUG" = true ] && set -x; locate -i -r "$ARG"); done |(
     
     set -- grep -iE "($(IFS='| '; echo "$*"))$ANY\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"; 
     [ "$DEBUG" = true ] && set -x
     "$@"
     
     )
  )
}

locate_filenames "$@"