#!/bin/bash

: ${MYNAME=`basename "$0" .sh`}

archives_EXTS="rar zip 7z cab cpio cpio.Z cpio.gz cpio.xz cpio.bz2 cpio.lzma tar tar.Z tar.gz tar.xz tar.bz2 tar.lzma tar.zst cpio cpio.Z cpio.gz cpio.xz cpio.bz2 cpio.lzma  cpio cpio.Z cpio.gz cpio.xz cpio.bz2 cpio.lzma tgz txz tbz2 tlzma zst"
audio_EXTS="aif aiff flac m4a m4b mp2 mp3 mpc ogg raw rm wav wma"
books_EXTS="pdf epub mobi azw3 djv djvu"
documents_EXTS="cdr doc docx odf odg odp ods odt pdf ppt pptx rtf vsd xls xlsx html"
fonts_EXTS="CompositeFont pcf ttc otf afm pfb fon ttf"
grammar_EXTS="ebnf bnf g4 y l"
images_EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff opc pbm pcx pgm pgx png pnm ppm psd rle rmp sgi shx svg tga tif tiff wim xcf xpm xwd mng"
incomplete_EXTS="*.part *.!?? INCOMPL*"
music_EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff mod s3m xm it 669 mp4"
packages_EXTS="tgz txz rpm deb"
scripts_EXTS="sh py rb bat cmd js jsx cjs mjs ts tsx"
scripts_EXCL="d.js test.js d.ts test.ts test.d.ts"
software_EXTS="*setup*.exe *install*.exe *.msi *.msu *.cab *.vbox-extpack *.apk *.run *.dmg *.app *.apk 7z app bin daa deb dmg exe iso msi msu cab vbox-extpack apk nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz zip AppImage"
sources_EXTS="c cs cc cpp cxx h hh hpp hxx ipp mm r java rb py s asm inc"
scripts_EXTS="lua etlua moon py rb sh js jsx ts tsx es es5 es6 es7 coffee scss sass css jsx tcl pl awk m4 php"
web_EXTS="js css htm html"
videos_EXTS="3gp avi f4v flv m4v m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"
vmdisk_EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"
project_EXTS="avrgccproj bdsproj cbproj coproj cproj cproject csproj dproj fsproj groupproj jsproj jucer lproj lsxproj metaproj packproj pbxproj pkgproj pmproj pnproj pro proj project pssproj shfbproj sln tmproj unityproj uvproj vbproj vcproj vcxproj vdproj vfproj webproj winproj wixproj zdsproj zfpproj"
spice_EXTS="sp cir spc spi"
eda_EXTS="sch brd lbr"
bin_EXTS="hex cof"
proteus_EXTS="dsn pdsproj"
js_EXTS="js jsx es5 es6"
cad_EXTS="jscad stl nc"
cam_EXTS="sts sol hpgl dri gpi 274 exc std"

addexts() {
  eval "EXTS=\"\${EXTS:+\$EXTS }\${${1}_EXTS}\""
  eval "EXCL=\"\${EXCL:+\$EXCL }\${${1}_EXCL}\""
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
       append CONDITIONS -name "*.$EXT${S}"
		done

    if [ -n "$EXCL" ]; then
      EXCLUSIONS=
      for EXT in $EXCL; do
         [ "$EXCLUSIONS" ] && append EXCLUSIONS -or
         append EXCLUSIONS -name "*.$EXT${S}"
      done

      CONDITIONS="${CONDITIONS:+$CONDITIONS${NL})${NL}-and${NL}}-not${NL}(${NL}$EXCLUSIONS"
    fi

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
	  -depth | -maxdepth | -mindepth | -amin | -anewer | -atime | -cmin | -cnewer | -ctime | -fstype | -gid | -group | -ilname | -name | -inum | -iwholename | -iregex | -links | -lname | -mmin | -mtime | -name | -newer | -path | -perm | -regex | -wholename | -size | -type | -uid | -used | -user | -xtype | -context | -printf | -fprint0 | -fprint | -fls) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1$NL$2"; shift 2 ;;
	  -print | -daystart | -follow | -regextype | -mount | -noleaf | -xdev | -ignore_readdir_race | -noignore_readdir_race | -empty | -false | -nouser | -nogroup | -readable | -writable | -executable | -true | -delete | -print0 | -ls | -prune | -quit) EXTRA_ARGS="${EXTRA_ARGS:+$EXTRA_ARGS$NL}$1"; shift ;;
	  -q|--shell_quote) EXPR=$EXPR'; s|"|\\"|g; s|.*|"&"|'; shift ;;
	  -c|--completed) COMPLETED="true"; shift ;;
	  -x|-d|--debug) DEBUG="true"; shift ;;
	  *) break ;;
	esac
  done

  ARGS="$*"

  if [ "${COMPLETED-false}" = true ]; then
 	   EXCL="${EXCL:+$EXCL${NL}}part${NL}!??${NL}crdownload"
  fi

	find_filename "$@" || return $?
}

main "$@"
