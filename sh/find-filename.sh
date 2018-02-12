#!/bin/bash

: ${MYNAME=`basename "$0" .sh`}

archives_EXTS="rar zip 7z cab tar tar.Z tar.gz tar.xz tar.bz2 tar.lzma tgz txz tbz2 tlzma"
audio_EXTS="aif aiff flac m4a m4b mp2 mp3 mpc ogg raw rm wav wma"
books_EXTS="pdf epub mobi azw3 djv djvu"
fonts_EXTS="mp3 ogg flac mpc m4a m4b wma rm"
images_EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff opc pbm pcx pgm pgx png pnm ppm psd rle rmp sgi shx svg tga tif tiff wim xcf xpm xwd mng"
incomplete_EXTS="*.part *.!?? INCOMPL*"
music_EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff mod s3m xm it 669 mp4"
packages_EXTS="tgz txz rpm deb"
scripts_EXTS="sh py rb bat cmd"
software_EXTS="*setup*.exe *install*.exe *.msi *.msu *.cab *.vbox-extpack *.apk *.run *.dmg *.app *.apk 7z app bin daa deb dmg exe iso msi msu cab vbox-extpack apk nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz zip"
sources_EXTS="c cs cc cpp cxx h hh hpp hxx ipp mm r java S s asm"
videos_EXTS="3gp avi f4v flv m4v m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"
vmdisk_EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"
project_EXTS="avrgccproj bdsproj cbproj coproj cproj cproject csproj dproj fsproj groupproj jsproj jucer lproj lsxproj metaproj packproj pbxproj pkgproj pmproj pnproj pro proj project pssproj shfbproj sln tmproj unityproj uvproj vbproj vcproj vcxproj vdproj vfproj webproj winproj wixproj zdsproj zfpproj"
spice_EXTS="sp cir spc spi"
eda_EXTS="sch brd lbr"

addexts() {
eval "EXTS=\"\${EXTS:+\$EXTS }\${${1}_EXTS}\""
}
addexts ${MYNAME#find-}

CYGPATH=` which cygpath 2>/dev/null` 
NL="
"
#: ${CYGPATH:=true}

# append <var> <value>
append()
{
  eval "shift; ${1}=\${$1:+\${$1}\${NL}}\$*"
}

find_filename()
{
	(IFS="
	 "

		[ "$#" -le 0 ] && set -- *

		set -f 
		set find "$@" $EXTRA_ARGS

		CONDITIONS=

		for EXT in $EXTS; do
			 [ "$CONDITIONS" ] && append CONDITIONS -or
       append CONDITIONS -iname "*.$EXT${S}"
		done

		CONDITIONS="-type${NL}f${NL}-and${NL}(${NL}${CONDITIONS}${NL})" 
		set "$@"  $CONDITIONS 

    ${DEBUG-false} && echo "+ $@" 1>&2

		("$@" 2>/dev/null)  |${SED-sed} -u "$EXPR"
	)
}

main() {
  IFS="
  "
  EXPR='s,^\.\/,,'

  while :; do
	case "$1" in
	  -depth | -maxdepth | -mindepth | -amin | -anewer | -atime | -cmin | -cnewer | -ctime | -fstype | -gid | -group | -ilname | -iname | -inum | -iwholename | -iregex | -links | -lname | -mmin | -mtime | -name | -newer | -path | -perm | -regex | -wholename | -size | -type | -uid | -used | -user | -xtype | -context | -printf | -fprint0 | -fprint | -fls) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1$NL$2"; shift 2 ;;
	  -print | -daystart | -follow | -regextype | -mount | -noleaf | -xdev | -ignore_readdir_race | -noignore_readdir_race | -empty | -false | -nouser | -nogroup | -readable | -writable | -executable | -true | -delete | -print0 | -ls | -prune | -quit) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1"; shift ;;
	  -q|--quote) EXPR=$EXPR'; s|"|\\"|g; s|.*|"&"|'; shift ;;
	  -c|--completed) COMPLETED="true"; shift ;;
	  -x|-d|--debug) DEBUG="true"; shift ;;
	  *) break ;;
	esac
  done

  ARGS="$*"

  set -- ''

  if ! ${COMPLETED-false}; then
	set -- "$@" '*.part' '.!??'
  fi

  for S; do
	S="$S" find_filename $ARGS || return $?
  done
}

main "$@"
