#!/bin/sh

: ${MYNAME=`basename "$0" .sh`}

grep_filename() {
  BS="\\"
  FS="/"
  archives_EXTS="rar zip 7z cab tar tar.Z tar.gz tar.xz tar.lzma tar.bz2 tar.lzma tgz txz tbz2 tlzma cpio"
  audio_EXTS="mp3 mp2 m4a m4b wma rm ogg flac mpc wav aif aiff raw"
  books_EXTS="pdf epub mobi azw3 djv djvu"
  documents_EXTS="cdr doc docx odf odg odp ods odt pdf ppt pptx rtf vsd xls xlsx"
  fonts_EXTS="otf ttf fon bdf pcf"
  fonts_EXTS="ttf otf bdf pcf fon"
  images_EXTS="bmp cin cod dcx djvu emf fig gif ico im1 im24 im8 jin jpeg jpg lss miff png pnm"
  music_EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff mod s3m xm it 669 mp4"
  packages_EXTS="txz tlzma tgz rpm deb"
  scripts_EXTS="sh py rb bat cmd"
  software_EXTS="rar zip 7z tar.gz tar.xz tar.lzma tar.bz2 tgz txz tlzma tbz2 exe msi msu cab vbox-extpack apk deb rpm iso daa dmg run pkg app bin iso daa nrg dmg exe sh tar.Z tar.gz zip"
  software_EXTS="$software_EXTS 7z app bin daa deb dmg exe iso msi msu cab vbox-extpack apk nrg pkg rar rpm run sh tar.Z tar.bz2 tar.gz tar.xz tbz2 tgz txz tlzma zip"
    sources_EXTS="c cs cc cpp cxx h hh hpp hxx ipp mm r java rb py S s asm"
    scripts_EXTS="lua moon py rb sh js coffee scss sass css jsx tcl pl awk m4 php"
    web_EXTS="js css htm html"
  videos_EXTS="3gp avi f4v flv m4v m2v mkv mov mp4 mpeg mpg ogm vob webm wmv"
  vmdisk_EXTS="vdi vmdk vhd qed qcow qcow2 vhdx hdd"
  project_EXTS="avrgccproj bdsproj cbproj coproj cproj cproject csproj dproj fsproj groupproj jsproj jucer lproj lsxproj metaproj packproj pbxproj pkgproj pmproj pnproj pro proj project pssproj shfbproj sln tmproj unityproj uvproj vbproj vcproj vcxproj vdproj vfproj webproj winproj wixproj zdsproj zfpproj"
  spice_EXTS="sp cir spc spi"
  eda_EXTS="sch brd lbr"

  pushv ()
  {
	  eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
  }

  addexts() {
    case "$1" in
      [A-Za-z]*) eval "EXTS=\"\${EXTS:+\$EXTS }\${${1}_EXTS}\"" ;;
    esac
  }
  addext() {
  eval "EXTS=\"\${EXTS:+\$EXTS }\${1}\""
  }
  addexts ${MYNAME#grep-}

  usage() {
    echo "$MYNAME [options] [patterns...]
    
 -x, --debug              Debug mode
 -c, --class CLASS        File type class
 -E, --extension EXT      Add file extension
 -C, --incomplete         Show incomplete (*.part) files
 " 
 exit 1
  }

  PARTIAL_EXPR="(\.part|\.!..|)"
  END="(|[\&\?\" ][^/]*)${cr}?\$"
  while :; do
	case "$1" in
	-h | --help) usage ;;
	  -x | --debug) DEBUG=true; shift ;;
	  -c | --class) addexts "$2"; shift  2 ;;
	  -c=* | --class=*) addexts "${1#*=}"; shift ;;
	  -c*) addexts "${1#-?}"; shift   ;;
	  -E=* | --ext*=*) addext "${1#*=}"; shift ;;
		  -E | --ext*) addext "$2"; shift  2 ;;
	  -E*) addext "${1#-?}"; shift   ;;
  #    -c | --complete) PARTIAL_EXPR="" ; shift ;;
      -A | --addexpr) pushv EXPRS "$2"; shift 2 ;;
      -A*) pushv EXPRS "${1#-?}"; shift 1 ;;
      -A=* | --addexpr=*) pushv EXPRS "${1#*=}"; shift 1 ;;
	  -C | --incomplete) END="" ; shift ;;
	  -b | -F | -G | -n | -o | -P | -q | -R | -s | -T | -U | -v | -w | -x | -z) GREP_ARGS="${GREP_ARGS:+$GREP_ARGS
  }$1"; shift ;;
	  *) break ;;
	esac
  done

  cr=""
  GREP_ARGS="${GREP_ARGS:+$GREP_ARGS }--binary-files=text"

#  CMD='grep $GREP_ARGS -i -E "\\.($(IFS="| "; set -- $EXTS;  echo "$*"))${PARTIAL_EXPR}${END}"  "$@"'
 #CMD='grep $GREP_ARGS -i -E "('

CMD=
  for E in $EXTS; do
    X="\\.$E${PARTIAL_EXPR}${END}"
    
    CMD=${CMD:+"$CMD|"}$X
  done
  for X in $EXPRS; do
    CMD="${CMD:+$CMD|}$X"
  done

  CMD="grep \$GREP_ARGS -i -E '($CMD)'  \"\$@\""
 
  if [ $# -gt 1 ]; then
    GREP_ARGS="-H"
    case "$*" in
      *files.list*) FILTER='${SED-sed} "s|/files.list:|/|"' ;;
    esac
  fi

  [ -n "$FILTER" ] && CMD="$CMD | $FILTER" || CMD="exec $CMD"
  [ "$DEBUG" = true ] && eval "echo \"+ \$CMD\" 1>&2"

  eval "$CMD"
}

grep_filename "$@"
