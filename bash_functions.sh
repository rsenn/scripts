#!/bin/bash

absdir()
{
    case $1 in
        /*)
            echo "$1"
        ;;
        *)
            ( cwd=`pwd` && cd "$cwd${1:+/$1}" && echo "$cwd${1:+/$1}" || {
                cd "$1" && pwd
            } )
        ;;
    esac 2> /dev/null
}

abspath()
{
    if [ -e "$1" ]; then
        local dir=`dirname "$1"` && dir=`absdir "$dir"`;
        echo "${dir%/.}/${1##*/}";
    fi
}

add-cond-include() {
 (INC="$1"
  shift

  INCNAME="${INC##*/include/}"
  INCDEF=HAVE_$(echo "$INCNAME" | sed 's,[/.],_,g' | tr '[[:'{lower,upper}':]]') 

  sed -i "\\|^\s*#\s*include\s\+[<\"]\s*$INCNAME[>\"]| {
    s|.*|#ifdef $INCDEF\n&\n#endif /* defined $INCDEF */|
  }" "$@"

  )
}

addprefix() {
 (PREFIX=$1; shift
  CMD='echo "$PREFIX$LINE"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}

addsuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "$LINE$SUFFIX"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}

all-disks()
{
   (case "$1" in
      -l) SHOW_LABEL=true; shift ;;
      -u) SHOW_UUID=true; shift ;;
    esac
    if [ -z "$1" ]; then
        set -- /dev/disk/by-{uuid,label};
    fi;
    find "$@" -type l | while read -r FILE; do
       if [ "$SHOW_LABEL" = true ]; then
	 case "$FILE" in
	     /dev/disk/by-label/*) echo "LABEL=${FILE##*/}" ;;
	 esac
       elif [ "$SHOW_UUID" = true ]; then
	 case "$FILE" in
	     /dev/disk/by-uuid/*) echo "UUID=${FILE##*/}" ;;
	 esac
       else
        myrealpath "$FILE";
       fi
    done | sort -u
    )
}

array()
{
    local IFS="$ARRAY_s";
    echo "$*"
}

aspect()
{
    ( case "$#" in
        1)
            W="${1%%x*}" H="${1#*x}"
        ;;
        2)
            W="$1" H="$2"
        ;;
    esac;
    GCD=$(gcd "$W" "$H");
    echo "$((W / GCD)):$((H / GCD))" )
}

autorun-shell()
{
   (EXEC="$1"
     shift
     [ $# -le 0 ] && set -- $(echo "$EXEC" |sed 's,Start,Start , ; s,\.exe,,g')
    echo "Shell\\Option1=$*
Shell\\Option1\\Command=$EXEC
")
}

awkp()
{
    ( IFS="
	";
    N=${1};
    set -- awk;
    case $1 in
        -[A-Za-z]*)
            set -- "$@" "$1";
            shift
        ;;
    esac;
    "$@" "{ print \$${N:-1} }" )
}

bheader()
{
    quiet dd count="${1:-1}" bs="${2:-512}"
}

bitrate()
{
  ( N=$#
  for ARG in "$@";
  do
    #EXPR="\\s[^:]*\\s\\+\\([0-9]\\+\\)\\s*kbps.*"
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*kbps.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1,p"

    KBPS=$(file "$ARG" |sed -n "$EXPR")
    #echo "EXPR='$EXPR'" 1>&2

    test -n "$KBPS" && echo "$KBPS" || (
    R=0
    set -- $(mminfo "$ARG"  |sed -n "/[Oo]verall [bB]it [Rr]ate\s*=/ { s,\s*Kbps\$,, ;  s|\([0-9]\)\s\+\([0-9]\)|\1\2|g ; s,\.[0-9]*\$,, ; s,^[^=]*=,,; s|^|$ARG:|; p }")
[ "$DEBUG" = true ] && echo "BR: $*" 1>&2
   #echo "$*" 1>&2
   # for I; do R=` expr $R + ${I##*=}` ; done 2>/dev/null
	 R=${*##*:}
   [ "$N" -gt 1 ] && R="$ARG:$R"
      echo "$R"
      )
  done )
}

blksize()
{
    ( SIZE=`fdisk -s "$1"`;
    [ -n "$SIZE" ] && expr "$SIZE" \* 512 / ${2-512} )
}

blkvars()
{
  CMD=$(IFS=" "; set -- `blkid "$1"`; shift; echo "$*")
	shift
	if [ $# -gt 0 ]; then
		for V; do
			CMD="$CMD; echo \"\${$V}\""
		done
		CMD="($CMD)"
	fi
	eval "$CMD"
}

bpm() {
  id3v2  -l "$@"|sed -n "/^id3v2 tag info for / {
		:lp     
		N
		/\n[[:upper:][:digit:]]\+ ([^\n]*$/ {
			/\nTBPM[^\n]*$/! {
				s|\n[^\n]*$||
				b lp
			}
			s|TBPM (.*): ||g
			b ok
		}
		/:\s*$/! {
			s|\n| |g
			b lp
		}
		:ok     
		s|\n[^\n]*:\s*$||
		s|^id3v2 tag info for \([^\n]*\) *: *\n *|\1: |
		p
  }"
}

#bpm()
#{
#    ( unset NAME;
#    if [ $# -gt 1 ]; then
#        NAME=":";
#    fi;
#    for ARG in "$@";
#    do
#        BPM=` id3v2 -l "$ARG" |sed -n 's,TBPM[^:]*:\s*,,p' `;
#        echo "${NAME+$ARG: }${BPM%.*}";
#    done )
#}

c256()
{
  value=$1
  value=$(( ((value & 0x0F) << 4) | ((value & 0xF0) >> 4) ))
  value=$(( ((value & 0x33) << 2) | ((value & 0xCC) >> 2) ))
  value=$(( ((value & 0x55) << 1) | ((value & 0xAA) >> 1) ))
  echo "$value"
}

c2w()
{
    ch_conv UTF-8 UTF-16 "$@"
}

canonicalize()
{
  (IFS="
 -"
   while :; do
   case "$1" in
     -l|--lowercase) LOWERCASE=true; shift ;;
     -m=|--maxlen=) MAXLEN="${1#*=}"; shift ;;
     -m|--maxlen) MAXLEN="$2"; shift 2 ;;
     *) break ;;
     esac
   done
     : ${MAXLEN:=4095}

   CMD="sed 's,[^A-Za-z0-9],-,g'|sed 's,-\+,-,g ;; s,^-\+,, ;; s,-\+\$,,'"
   [ "$LOWERCASE" = true ] && CMD="$CMD|tr [:{upper,lower}:]"
   #[ $# -gt 0 ] && CMD='set -- \$(IFS=" "; echo "$*"|'$CMD')'

   set -- $(echo "$*"|eval "$CMD")

   unset OUT

   while [ $# -gt 0 ]; do
      [ -z "$1" ] && continue
     NEWOUT="${OUT:+$OUT-}$1"
     [ ${#NEWOUT} -gt ${MAXLEN} ] && break
     OUT="$NEWOUT"
     shift
   done

   echo "$OUT"

   )
}

ch_conv()
{
    FROM="$1" TO="$2";
    shift 2;
    for ARG in "$@";
    do
        ( trap 'rm -f "$TMP"' EXIT;
        TMP=$(mktemp);
        iconv -f "$FROM" -t "$TO" <"$ARG" >"$TMP" && mv -vf "$TMP" "$ARG" );
    done
}
c2w()
{
    ch_conv UTF-8 UTF-16 "$@"
}
w2c()
{
    ch_conv UTF-16 UTF-8 "$@"
}

check-7z() {
 (while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  IFS="
"
  output() {
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  }
  OUTDIR="$PWD/Check-$RANDOM"
  rm -rf "$OUTDIR"
  mkdir -p "$OUTDIR"
  trap 'rm -rf "$OUTDIR"' EXIT
	FILTER="xargs -n1 -d \"\${IFS:0:1}\" sha1sum"
	#FILTER="$FILTER | sed \"s|^\\([0-9a-f]\\+\\)\\s\\+\\*\\(.*\\)|\${ARCHIVE}\${SEP:-: }\\2 \\[\\1\\]|\""
	FILTER="$FILTER | sed \"s|^\\([0-9a-f]\\+\\)\\s\\+\\*\\(.*\\)|\\1 \\*\${ARCHIVE}\${SEP:-:}\\2|\""
  process() { IFS="
 "; set +x; 
		unset PREV; while read -r LINE; do
		LINE=${LINE//"\\"/"/"}
		 case "$LINE" in
		 "Extracting: "*) ARCHIVE=${LINE#"Extracting: "}; echo "Archive=${ARCHIVE}" 1>&2; continue ;;
			"Extracting  "*)
					FILE=${LINE#"Extracting  "}
					if [ -n "$FILE" -a "$FILE" != "$PREV" ]; then
#				    echo "FILE='$FILE'" 1>&2
					[ "$FILE" = "$T" ] && continue 			    
						if [ -e "$FILE" ]; then [ -f "$FILE" ] && echo "$FILE"
						else echo "File '$FILE' not found!" 1>&2; fi
					fi
				PREV="$FILE" ;;
		 esac; done
	}
  while [ $# -gt 0 ]; do
   (B=${1##*/}
    case "$1" in 
      *://*) INPUT="curl -s \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
    esac
    case "$1" in 
      *.t?z | *.tbz2)
        T=${1%.t?z}
        T=${T%.tbz2} 
        T=$T.tar
        INPUT="${INPUT:+$INPUT | }${SEVENZIP:-7za} x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${T}";  CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" $OPTS"
			  ;;
      *.tar.*) T=${1%.tar*}.tar;
      INPUT="${INPUT:+$INPUT | }${SEVENZIP:-7za} x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si${B%.*}";  CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" $OPTS" ;;
      *) CMD="${SEVENZIP:-7za} x -o\"$OUTDIR\" -y $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    T=${T##*/}
    	    #echo "T='$T'" 1>&2
      if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si${1##*/}"
    fi 
      CMD="($CMD) 2>&1 | (cd \"\$OUTDIR\" >/dev/null; process${FILTER:+ | $FILTER})"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2 
     eval "$CMD") || exit $?
    shift
  done)
}

check-link()
{
  (TARGET=$(readshortcut "$1")
    test -e "$TARGET")
}

choices_list()
{
    local n=$1 count=0 choices='';
    shift;
    for choice in "$@";
    do
        choices="$choices $choice";
        count=$((count + 1));
        if $((count)) -eq $((n)); then
            count=0;
            choices='';
        fi;
    done;
    if [ -n "${choices# }" ]; then
        msg $choices;
    fi
}

chr2hex()
{
    echo "set ascii [scan \"$1\" \"%c\"]; puts -nonewline [format \"${2-0x}%02x\" \${ascii}]" | tclsh
}

ch_conv()
{
    FROM="$1" TO="$2";
    shift 2;
    for ARG in "$@";
    do
        ( trap 'rm -f "$TMP"' EXIT;
        TMP=$(mktemp);
        iconv -f "$FROM" -t "$TO" <"$ARG" >"$TMP" && mv -vf "$TMP" "$ARG" );
    done
}

clamp()
{
    local int="$1" min="$2" max="$3";
    if [ "$int" -lt "$min" ]; then
        echo "$min";
    else
        if [ "$int" -gt "$max" ]; then
            echo "$min";
        else
            echo "$int";
        fi;
    fi
}

command-exists()
{
    type "$1" 2> /dev/null > /dev/null
}

compare-dirs()
{
     diff -ru "$@" | sed -n \
         -e "/^Binary files/ s,^Binary files \(.*\) and \(.*\) differ,\1 \2,p" \
         -e "s,^Only in \(.*\): \(.*\),\1/\2,p" \
         -e "/^diff/ { N; /\n---/ { N; /\n+++/ { s,\n.*,, ;; s,^diff\s\+,, ;; s,^-[^ ]* ,,g ;; p } } }"
}

convert-boot-entries()
{
  ([ -z "$FORMAT" ] && FORMAT="$1"

    for FILE; do
      convert-boot-file "$FILE" "$FORMAT"
    done
  )
}

convert-boot-file()
{
  (if [ -e "$1" ]; then
     exec <"$1"
     shift
   fi

   [ -z "$FORMAT" ] && FORMAT="$1"

   while parse-boot-entry; do
     output-boot-entry "$FORMAT"
   done



   )
}

count-in-dir()
{
				 (LIST="$1"; shift; for ARG; do
				 N=$(grep "^${ARG%/}/." "$LIST" | wc -l)
				 echo $N "$ARG"
 done)
}

count-lines()
{
    ( [ $# -le 0 ] && set -- -;
    N=$#;
    for ARG in "$@";
    do
        ( set -- $( (xzcat "$ARG" 2>/dev/null ||zcat "$ARG" 2>/dev/null || bzcat "$ARG" 2>/dev/null || cat "$ARG") | wc -l);
        [ "$N" -le 1 ] && echo "$1" || printf "%10d %s\n" "$1" "$ARG" );
    done )
}

count() {
        echo $#
}

cpan-install()
{ 
    for ARG in "$@";
    do
        perl -MCPAN -e "CPAN::Shell->notest('install', '$ARG')";
    done
}

cpan-search()
{ 
    ( for ARG in "$@";
    do
        ARG=${ARG//::/-};
        URL=$(dlynx.sh "http://search.cpan.org/search?query=$ARG&mode=dist" |grep "/$ARG-[0-9][^/]*/\$" | sort -V | tail -n1 );
        test -n "$URL" && { 
            dlynx.sh "$URL" | grep-archives.sh | sort -V | tail -n1
        };
    done )
}

create-shortcut()
{
 (declare "$@"
  (set -x; mkshortcut ${ARGS:+-a
"$ARGS"} ${ICON:+-i
"$ICON"} ${ICONOFFSET:+-j
"$ICONOFFSET"} ${DESC:+-d
"$DESC"} ${NAME:+-n
"$NAME"} ${WDIR:+-w
"$WDIR"} \
"$TARGET")
  )
}

ctime()
{
    ( TS="+%s";
    while :; do
        case "$1" in
            +*)
                TS="$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    NW="[^ ]\+";
    WS=" \+";
    E="^${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E\(${NW}\)${WS}";
    E="$E\(.*\)";
    [ $# -gt 1 ] && R="\2: \1" || R="\1";
    ls --color=auto --color=auto --color=auto -l -n -d --time=ctime --time-style="${TS}" "$@" | sed "s/$E/$R/" )
}

cut-arch()
{
    sed 's,^\([^ ]*\)\.[^ .]*\( - \)\?\(.*\)$,\1\2\3,'
}

cut-basename()
{
    sed 's,[/\\][^/\\]*[/\\]\?$,,'
}

cut-dirname()
{
    sed "s,\\(.*\\)[/\\\\]\\([^/\\\\]\\+[/\\\\]\\?\\)${1//./\\.}\$,\2,"
}

cut-distver()
{
  cat "$@" | sed 's,\.fc[0-9]\+\(\.\)\?,\1,g'
}

cut-dotslash()
{
  sed -u 's,^\.[/\\],,'
}

cut-ext() {
 (CMD='sed -e "/\\.exe\$/ { s|\\.paf\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.gz\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.bz2\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.lzma\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.xz\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "/\\.Z\$/ { s|\\.tar\\(\\.[^.]\\+\\)\$|\\1| }" -e "s,\\.[^./]\\+\$,,"'
  CMD="$CMD${@:+ \"\$@\"}"
  eval "$CMD")
}

cut-hexnum()
{
  sed 's,^\s*[0-9a-fA-F]\+\s*,,' "$@"
}

cut-ls-l()
{
    ( I=${1:-6};
    set --;
    while [ "$I" -gt 0 ]; do
        set -- "ARG$I" "$@";
        I=`expr $I - 1`;
    done;
    IFS=" ";
    CMD="while read  -r $* P; do  echo \"\${P}\"; done";
   #echo "+ $CMD" 1>&2;
    eval "$CMD" )
}

cut-lsof()
{
    ( IFS=" ";
    eval "while read -r COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME; do
  if ( ! [ \"\$NODE\" -ge 0 ] 2>/dev/null ) || [ -z \"\$NAME\" ]; then NAME=\"\$NODE\${NAME:+ \$NAME}\"; unset NODE; fi;   echo \"\${${1-NAME}}\"; done" )
}

cut-num()
{
  sed 's,^\s*[0-9]\+\s*,,' "$@"
}

cut-pkgver()
{
    cat "$@" |sed 's,-[0-9]\+$,,g'
}

cut-trailver() {
 (CMD='sed -e "s|[-_][0-9][^-_.]*\\(\\.[0-9][^-.]*\\)*\$||" -e "s|[-_.]\\?[0-9]\\+\.[.0-9]\+\$||"'
  CMD="$CMD${@:+ \"\$@\"}"
  eval "$CMD")
}

cut-ver()
{
  cat "$@" | cut-trailver |
  sed 's,[-.]rc[[:alnum:]~][^-.]*,,g ;; s,[-.]b[[:alnum:]~][^-.]*,,g ;; s,[-.]git[_[:alnum:]~][^-.]*,,g ;; s,[-.]svn[_[:alnum:]~][^-.]*,,g ;; s,[-.]linux[^-.]*,,g ;; s,[-.]v[[:alnum:]~][^-.]*,,g ;; s,[-.]beta[_[:alnum:]~][^-.]*,,g ;; s,[-.]alpha[_[:alnum:]~][^-.]*,,g ;; s,[-.]a[_[:alnum:]~][^-.]*,,g ;; s,[-.]trunk[^-.]*,,g ;; s,[-.]release[_[:alnum:]~][^-.]*,,g ;; s,[-.]GIT[^-.]*,,g ;; s,[-.]SVN[^-.]*,,g ;; s,[-.]r[_[:alnum:]~][^-.]*,,g ;; s,[-.]dnh[_[:alnum:]~][^-.]*,,g' |
  sed 's,[^-.]*git[_0-9][^.].,,g ;; s,[^-.]*svn[_0-9][^.].,,g ;; s,[^-.]*GIT[^.].,,g ;; s,[^-.]*SVN[^.].,,g' |
  sed 's,\.\(P\)\?[[:digit:]][_+[:digit:]]*\.,.,g' |
  sed 's,-\([0-9]\+\):\([0-9]\+\),-\1.\2,' | 
  sed 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]][_+[:alnum:]~]*\([-.]\),\1,g'|
  sed 's,[-_.][[:digit:]]*\(svn\)\?\(git\)\?\(P\)\?\(rc\)\?[[:digit:]][_+[:digit:]]*\(-.\),\5,g' |
  sed 's,-[[:digit:]][._+[:digit:]]*$,, ;;  s,-[[:digit:]][._+[:digit:]]*$,,'  |
  sed 's,[.-][[:digit:]][_+[:alnum:]~]*$,,g ;; s,[.-][[:digit:]]*\(rc[[:digit:]]\)\?\(b[[:digit:]]\)\?\(git[_0-9]\)\?\(svn[_0-9]\)\?\(linux\)\?\(v[[:digit:]]\)\?\(beta[_0-9]\)\?\(alpha[_0-9]\)\?\(a[_0-9]\)\?\(trunk\)\?\(release[_0-9]\)\?\(GIT\)\?\(SVN\)\?\(r[_0-9]\)\?\(dnh[_0-9]\)\?[[:digit:]][_+[:alnum:]~]*\.,.,g' |
  sed 's,\.[[:digit:]][^.]*\.,.,g'

}

d()
{
    ( case "$1" in
        ?:*)
            set -- /cygdrive/${1%%:*}${1#?:}
        ;;
    esac;
    echo "$1" )
}

datasheet-url()
{ 
    RESULTS=1000 google.sh "$1 datasheet filetype:pdf" | grep --color=auto --line-buffered -i "$1[^/]*$"
}

date2unix()
{
    date --date "$1" "+%s"
}

debug()
{
    msg "DEBUG: $@"
}

dec2bin() {
 (NUM="$*"
  for N in $NUM; do
    case "$N" in
      0x*) eval "N=\$(($N))" ;;
    esac
    echo "obase=2;$N" | bc -l
  done | addprefix "${P-0b}")
}

decompress-7z() {
 (while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#

  output() {
    [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
  }
  
  [ $# -le 0 ] && set -- -

  while [ $# -gt 0 ]; do
   (case "$1" in 
      *://*) INPUT="curl -s \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
      -) OPTS="${OPTS:+$OPTS }-si" ;;
    esac
    OPTS=${OPTS:+$OPTS }"-so"
    CMD="7z x \$OPTS ${ARCHIVE+\"\$ARCHIVE\"}"
    eval "$CMD" )
    shift
  done)
}

decompress()
{
    local mime="$(file -bi "$1")";
    case $mime in
        application/x-bzip2)
            bzip2 -dc "$1"
        ;;
        application/x-gzip)
            gzip -dc "$1"
        ;;
        *)
            cat "$1"
        ;;
    esac
}

dec_to_hex()
{
    printf "%08x\n" "$1"
}

detect-filesystem()
{
    if [ -e "$1" ]; then
        filesystem-for-device "$(device-of-file "$1")";
    fi
}

device-of-file() {
 (for ARG in "$@"; do
  (if [ -e "$ARG" ]; then
     if [ -L "$ARG" ]; then
         ARG=`myrealpath "$ARG"`
     fi
     if [ -b "$ARG" ]; then
         echo "$ARG"
         exit 0
     fi
     if [ ! -d "$ARG" ]; then
         ARG=` dirname "$ARG" `
     fi
     DEV=`(grep -E "^[^ ]*\s+$ARG\s" /proc/mounts ;  df "$ARG" |sed '1d' )|awkp 1|head -n1`
     [ $# -gt 1 ] && DEV="$ARG: $DEV"

     [ "$DEV" = rootfs -o "$DEV" = /dev/root ] && DEV=`get-rootfs`

     echo "$DEV"
  fi)
  done)
}

diffcmp()
{
 (unset OPTS; while :; do
    case "$1" in
      --) shift; break ;;
      -*) OPTS="${OPTS+$OPTS$IFS}$1"; shift ;;
      *) break ;;
    esac
  done
  unset DIREXPR
  for ARG; do
    test -d "$ARG" || ARG=`dirname "$ARG"`
    DIREXPR="${DIREXPR+$DIREXPR ;; }s|^${ARG%/}/||"
  done

  LANGUAGE=C LC_ALL=C \
  diff $OPTS "$@" |
  sed -n \
    -e 's/^Binary files \(.*\) and \(.*\) differ/\1\n\2/p' \
    -e 's,^[-+][-+][-+]\s\+"\([^"]\+\)"\s.*,\1,p' \
    -e 's,^[-+][-+][-+]\s\+\([^"][^ \t]*\)\s.*,\1,p' \
    | sed -e "$DIREXPR" \
    | uniq)
}

diff_plus_minus()
{
    local IFS="$newline" d=$(diff -x .svn -ruN "$@" |
      sed -n -e "/^[-+][-+][-+]\s\+$1/d"                -e "/^[-+][-+][-+]\s\+$2/d"                -e '/^[-+]/ s,^\(.\).*$,\1, p' 2>/dev/null);
    IFS="-$newline ";
    eval set -- $d;
    local plus=$#;
    IFS="+$newline ";
    eval set -- $d;
    local minus=$#;
    echo "+$plus" "-$minus"
}

disk-device-for-partition()
{
    echo "${1%[0-9]}"
}

disk-device-letter()
{
    DEV="$1";
    DEV=${DEV##*/};
    echo "${DEV:2:1}"
}

disk-device-number()
{
    index-of "$(disk-device-letter "$1")" abcdefghijklmnopqrstuvwxyz
}

disk-devices() {
  wmic volume get DeviceID /VALUE | while read -r LINE; do
    case "$LINE" in
      *=*) echo "${LINE##*=}" ;;
    esac
  done
} ||

disk-devices() {
    foreach-partition 'echo "$DEV"'
}

disk-label() {
 (LABEL=`volname "$1"`
  if [ -n "$1" -a -e "$1" -a -n "$LABEL" ]; then
    echo "$LABEL"
    exit 0
  fi      
  ESCAPE_ARGS="-e"
  while :; do
    case "$1" in
      -E | --no-escape) ESCAPE_ARGS=; shift ;;
      *) break ;;
    esac
  done
  DEV=${1}
  test -L "$DEV" && DEV=` myrealpath "$DEV"`
  cd /dev/disk/by-label
  find . -type l | while read -r LINK; do
		TARGET=`readlink "$LINK"`
		if [ "${DEV##*/}" = "${TARGET##*/}" ]; then
			NAME=${LINK##*/}
			NAME=${NAME//'\x20'/'\040'}
			case "$NAME" in
				*[[:lower:]]*) LOWER=true ;;
			esac
			if [ "$LOWER" = true -o ! -r "$LINK" ]; then
				echo $ESCAPE_ARGS "$NAME"
			else
				FS=` filesystem-for-device "$DEV"`
				case "$FS" in
					*fat)
							IFS="
"
						set -- $(dosfslabel "$LINK")
						test $# = 1 && echo "$1"
					;;
					*) echo $ESCAPE_ARGS "$NAME" ;;
				esac
			fi
			exit 0
		fi
  done
  exit 1)
}

disk-partition-number()
{
    DEV="$1";
    DEV=${DEV##*/};
    echo "${DEV:3:1}"
}

disk-size()
{
    ( while :; do
        case "$1" in
            -m | -M)
                DIV=1024;
                shift
            ;;
            -g | -G)
                DIV=1048576;
                shift
            ;;
            -k | -K)
                DIV=1;
                shift
            ;;
            -b | -B)
                MUL=1024;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    R=$(sfdisk -s "$1");
    echo $(( R * ${MUL-1} / ${DIV-1} )) )
}

diskfree()
{
    set -- `df -B1 -P "$@" | tail -n1`;
    echo $4
}

divide-resolution()
{
    ( WIDTH=${1%%${MULT_CHAR-x}*};
    HEIGHT=${1#*${MULT_CHAR-x}};
    echo $((WIDTH / $2))${MULT_CHAR-x}$((HEIGHT / $2)) )
}

dl-slackpkg()
{
  (: ${DIR=/tmp}
   for PKG; do
     BASE=${PKG##*/}

wget -P "$DIR" -c "$PKG" && installpkg "$DIR/$BASE"|| break
  done)
}

dospath()
{
    ( case "$1" in
        ?:*)
            set -- /cygdrive/${1%%:*}${1#?:}
        ;;
    esac;
    echo "$1" )
}

du-txt()
{
    ( IFS="
";
    TMP="du.tmp$RANDOM";
    echo -n > "$TMP";
    trap 'rm -f "$TMP"' EXIT;
    CMD='(du -x -s -- ${@-$(ls-dirs)})';
    if [ -w "$TMP" ]; then
        CMD="$CMD | (tee \"\$TMP\"; sort -n -k1 <\"\$TMP\" >du.txt; rm -f \"\$TMP\"; echo \"Saved list into du.txt\" 1>&2)";
    fi;
    eval "$CMD" )
}

duration()
{
    ( IFS=" $IFS";
      CMD='echo "${ARG:+$ARG:}$S"'
    while :; do
       case "$1" in
         -m | --minute*) CMD='echo "${ARG:+$ARG:}$((S / 60))"' ; shift ;;
       *) break ;;
     esac
   done
    N="$#";
    for ARG in "$@"
    do
        D=$(mminfo "$ARG" |sed -n 's,Duration=,,p' | head -n1);
        set -- $D;
        S=0;
        for PART in "$@";
        do
            case $PART in
                *ms)
                    S=$(( (S * 1000 + ${PART%ms}) / 1000))
                ;;
                *mn)
                    PART=${PART%%[!0-9]*};
                    S=$((S + $PART * 60))
                ;;
                *h)
                    S=$((S + ${PART%h} * 3600))
                ;;
                *s)
                    S=$((S + ${PART%s}))
                ;;
            esac;
        done;
        [ "$N" -gt 1 ] && eval "$CMD" || ARG= eval "$CMD"
    done )
}

each()
{
    __=$1;
    test "`type -t "$__"`" = function && __="$__ \"\$@\"";
    while shift;
    [ "$#" -gt 0 ]; do
        eval "$__";
    done;
    unset __
}

enable-some-swap()
{
    ( SWAPS=` blkid|grep 'TYPE="swap"'|cut -d: -f1 `;
    set -- $SWAPS;
    for SWAP in $SWAPS;
    do
        if swapon "$SWAP"; then
            echo "Enabled swap device $SWAP" 1>&2;
            break;
        fi;
    done )
}

error()
{
    local retcode="${2:-1}";
    msg "ERROR: $@";
    if [ "$0" = "-sh" -o "${0##*/}" = "sh" -o "${0##*/}" = "bash" ]; then
        return "$retcode";
    else
        exit "$retcode";
    fi
}

errormsg()
{
    local retcode="${2:-$?}";
    msg "ERROR: $@";
    return "$retcode"
}

escape_required()
{
    local b="\\" q="\`\$\'\"${IFS}";
    case "$1" in
        '')
            return 1
        ;;
        ["$q"]* | *[!"$b"]["$q"]*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

eval_arith()
{
    eval "echo $(make_arith "$@")"
}

explode()
{
 (S="$1"; shift
  IFS="
";

  [ $# -gt 0 ] && exec <<<"$*"
  sed "s|${S//\"/\\\"}|\n|g"
 )
}

explore() {
 (r=`realpath "$1" 2>/dev/null`; [ "$r" ] || r=$1
  case "$r" in
    */*) ;;
    *) r=$PWD/$r ;;
  esac
  r=${r%/.}
  r=${r#./}
  bs="\\"
  fs="/"
  p=`$PATHTOOL -w "$r"`
  set -x
  "${SystemRoot:+$SystemRoot\\}cmd.exe" /c "explorer.exe /e,/root,${p//$bs/$fs}")
}

extract-slackpkg()
{
    : ${DESTDIR=unpack};
    mkdir -p "$DESTDIR";
    l=$(grep "$1" pkgs.files );
    pkgs=$(cut -d: -f1 <<<"$l" |sort -fu);
    files=$(cut -d: -f2 <<<"$l" |sort -fu);
    for pkg in $pkgs;
    do
        ( e=$(grep-e-expr $files);
        test -n "$files" && ( set -x;
        tar -C "$DESTDIR" -xvf "$pkg" $files 2> /dev/null ) );
    done
}

extract_version()
{
    echo "$*" | sed 's,^.*\([0-9]\+[-_.][0-9]\+[-_.0-9]\+\).*,\1,'
}

filesystem-for-device()
{
 (DEV="$1";
  set -- $(grep "^$DEV " /proc/mounts |awkp 3)
  case "$1" in
    fuse*)
      TYPE=$(file -<"$DEV");
      case "$TYPE" in
        *"NTFS "*) set -- ntfs ;;
        *"FAT (32"*) set -- vfat ;;
        *"FAT "*) set -- fat ;;
      esac
    ;;
    "")
      TYPE=$(file -<"$DEV");
      case "$TYPE" in
        *"swap "*) set -- swap ;;
      esac
    ;;
  esac
  echo "$1")
}

filter-cmd()
{
    ( IFS="
";
    CMD="$*";
    while read -r LINE; do
        ( case "$CMD" in
            *{}*)
                EXEC=${CMD//"{}"/"$LINE"};
                EVAL="\$EXEC || exit \$?"
            ;;
            *)
                EXEC="$CMD";
                EVAL="\$EXEC \"\$LINE\" || exit \$?"
            ;;
        esac;
        case "$EXEC" in
            *\ *)
                EVAL="$EXEC"
            ;;
            *)

            ;;
        esac;
        eval "$EVAL" ) || break;
    done )
}

filter-filemagic() {
(
 while :; do
	 case "$1" in
		 -c | --cut) CUT=true; shift ;;
		 *) break ;;
	 esac
 done
 [ "$CUT" = true ] && EXPR="s,:\\s\\+.*,,p" || EXPR="s,:\\s\\+,: ,p"

  [ $# -gt 0 ]  || set -- ".*"
	 for ARG; do
		 case "$ARG" in
			 "!"*) NOT="!" ARG=${ARG#$NOT} ;;
		   *) NOT="" ;;
		esac
		 EXPR="\\|:\\s\\+${ARG%%|*}|$NOT { $EXPR }"
	 done
  xargs -d "
" file -- | sed -n -u "$EXPR")
}

filter-filesize() {
  (OPS=
  IFS="
"; getnum() {
    N=$1
    case "$N" in
      *[Kk]) N=$(( ${N%[Kk]} * 1024 )) ;;
      *G) N=$(( ${N%G} * 1024 * 1048576)) ;;
      *T) N=$(( ${N%T} * 1048576 * 1048576)) ;;
      *M) N=$(( ${N%M} * 1048576 )) ;;
    esac
    echo "$N"
  }
  while :; do
    case "$1" in
      -gt | -ge | -lt | -le) OPS="${OPS:+$OPS$IFS}\$FILESIZE${IFS}$1${IFS}\$(($(getnum "$2")))"; shift 2 ;;
      -a | -o) OPS="${OPS:+$OPS$IFS}${1}"; shift ;;
      *) break ;;
    esac
  done
  xargs ls -l -d -n --time-style="+%s" -- | { 
   set -- $OPS
   IFS=" "
   CMD="test $*" 
   while read -r MODE N USERID GROUPID FILESIZE DATETIME PATH; do
     #echo "$FILESIZE" 1>&2
      eval "if $CMD; then echo \"\$PATH\"; fi" 

  done; }
  )
}

filter-git-status()
{
 (unset MATCH SUBST MODIFIER
  while :; do
    case "$1" in
      -v) MODIFIER='!'; shift ;;
    *) break ;;
    esac
  done
  WHAT=${1:-untracked}
  shift
  ARGS="-n"
  case "$WHAT" in
    untracked) MATCH="/^??\\s/" ;;
    merge*) MATCH="/^\\s\\?M/" ;;
    #*) echo "No such git status specifier: $WHAT" 1>&2; exit 1 ;;
  esac
  : ${SUBST="s|^...||p"}
  exec sed $ARGS "${MATCH:+$MATCH$MODIFIER} { $SUBST }")
}

filter-quoted-name()
{
  sed -n "s|.*\`\([^']\+\)'.*|\1|p"
}

filter-test()
{
  ( IFS="
  ";
  unset ARGS NEG;
  while :; do
      case "$1" in
          -a | -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s | -u | -w | -x)
              ARGS="${ARGS:+$ARGS
}"${NEG:+'!
'}"$1";

              shift;
              NEG=""
          ;;
          '!')
              [ "${NEG:-false}" = false ] && NEG='!' ||
              NEG=
              shift
          ;;
          *)
              break
          ;;
      esac;
  done;
  [ -z "$ARGS" ] && {
      exit 2
  };
  IFS=" ";
  set -- $ARGS;
  ARGN=$#;
  ARGS="$*";
  IFS="
"
  while read -r LINE; do
 set -- $LINE;
      #if [ $ARGN = 1 ]; then
          test $ARGS "$LINE" || continue 2;
      #else
      #    eval "test $ARGS \"\$LINE\"" || continue 2;
      #fi;
      echo "$LINE";
  done )
}

filter()
{
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in
                $PATTERN)
                    echo "$LINE";
                    break
                ;;
            esac;
        done;
    done )
}

filter_files_list()
{
    sed "s|/files\.list:|/|"
}

filter_out()
{
    ( while read -r LINE; do
        for PATTERN in "$@";
        do
            case "$LINE" in
                $PATTERN)
                    continue 2
                ;;
            esac;
        done;
        echo "$LINE";
    done )
}

find-all() { (locate32.sh "$@" ; find-media.sh "$@") |sort -u ; }

findstring()
{
    ( STRING="$1";
    while shift;
    [ "$#" -gt 0 ]; do
        if [ "$STRING" = "$1" ]; then
            echo "$1";
            exit 0;
        fi;
    done;
    exit 1 )
}

find_media()
{
    grep --color=auto --color=auto -iE "$(grep-e-expr "$@")" /{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}/files.list 2> /dev/null | filter_files_list | filter-test -e
}

first-char()
{
    echo "${*:0:1}"
}

firstletter()
{
    ( for ARG in "$@";
    do
        REST=${ARG#?};
        echo "${ARG%%$REST}";
    done )
}

fn2re()
{
    echo "$1" | sed -e 's,\.,\\.,g' -e "s,\\?,${2-.},g" -e "s,\\*,${2-.}*,g" -e 's,\[!\([^\]]\+\)\],[^\1],g'
}

for-each-char()
{
    x="$1";
    shift;
    s="$*";
    n=${#s};
    i=0;
    while [ "$i" -lt "$n" ]; do
        c=${s:0:1};
        eval "$x";
        s=${s#?};
        i=$((i+1));
    done
}

for-each-partition()
{
    ( SCRIPT="$1";
    shift;
    blkid "$@" | while read -r LINE; do
        DEV=${LINE%%": "*};
        VALUES=${LINE#*": "};
        ( eval "$VALUES";
        eval "$SCRIPT" );
    done )
}

foreach-mount()
{
    local old_IFS="$IFS";
    {
        IFS="
 ";
        while read -r DEV MNT TYPE OPTS A B; do
            eval "$*";
        done < /proc/mounts
    };
    IFS="$old_IFS"
}

foreach-partition() {
    local old_IFS="$IFS";
    blkid | {
        IFS="
 ";
        while read -r DEV VARS; do
            DEV=${DEV%:};
            eval "DEV=\"$DEV\" $VARS";
            eval "$*";
        done
    };
    IFS="$old_IFS"
}

for_each()
{
#    old_IFS=$IFS; IFS="$IFS "
    __=$1;
    test "`type -t "$__"`" = function && __="$__ \"\$@\"";
    while shift;
    [ "$#" -gt 0 ]; do
        eval "$__";
    done;
    unset __
#    IFS=$old_IFS
}

fstab-line()
{
    ( while :; do
        case "$1" in
            -u | --uuid) USE_UUID=true; shift ;;
            -l | --label) USE_LABEL=true; shift ;;
            *)
                break
            ;;
        esac;
    done;
    IFS="
 ";
    : ${MNT="/mnt"};
    for DEV in "$@";
    do
        ( unset DEVNAME LABEL MNTDIR #FSTYPE;
        DEVNAME=${DEV##*/};
        LABEL=$(disk-label -E "$DEV");
        [ -z "$MNTDIR" ] && MNTDIR="$MNT/${LABEL:-$DEVNAME}";
        : ${FSTYPE=$(filesystem-for-device "$DEV")}
        UUID=$(getuuid "$DEV");
        set -- $(proc-mount "$DEV");
        [ -n "$4" ] && : ${OPTS:="$4"};
        [ -n "$5" ] && DUMP="$5";
        [ -n "$6" ] && PASS="$6";
        [ "$USE_UUID" = true -a -n "$UUID" ] && DEV="UUID=$UUID";
        [ "$USE_LABEL" = true -a -n "$LABEL" -a -e /dev/disk/by-label/"$LABEL" ] && DEV="LABEL=$LABEL";
        case "$FSTYPE" in
            swap)
                MNTDIR=none;
                : ${OPTS:=sw}
            ;;
        esac;
        [ -z "$OPTS" ] && OPTS="$DEFOPTS"
        [ -n "$ADDOPTS" ] && OPTS="${OPTS:+$OPTS,}$ADDOPTS"


        [ "${FSTYPE}" = fuseblk ] && unset FSTYPE

				OPTS=${OPTS//,relatime/,noatime}
				OPTS=${OPTS//,blksize=[0-9]*/}
				OPTS=${OPTS//,errors=remount-ro/}
        printf "%-40s %-24s %-6s %-6s %6d %6d\n" "$DEV" "$MNTDIR" "${FSTYPE:-auto}" "${OPTS:-auto}" "${DUMP:-0}" "${PASS:-0}" );
    done )
}

fstentry()
{
    ( DEV="$1" TYPE=${2-auto} OPTS=${3-defaults};
    MNT=/media/${DEV##*/};
    blkvars "$DEV";
    echo -e "UUID=$UUID\t$MNT\t\t$TYPE\t$OPTS\t0 0" )
}

gcd()
{
    ( A="$1" B="$2";
    while :; do
        if [ "$A" = 0 ]; then
            echo "$B" && break;
        fi;
        B=$((B % A));
        if [ "$B" = 0 ]; then
            echo "$A" && break;
        fi;
        A=$((A % B));
    done )
}

get-bpm() {
  while :; do
    case "$1" in
      -i | --int*) INTEGER=true; shift ;;
      *) break ;;
    esac
  done
  [ $# -gt 1 ] && PFX="\$1: " || PFX=
  [ "$INTEGER" = true ] && DOT= || DOT="."
    CMD="sed -n \"/TBPM/ { s|.*TBPM\\x00\\x00\\x00\\x07\\x00*|| ;; s,[^${DOT}0-9].*,, ;; s|^|$PFX| ;;  p }\" \"\$1\""
  while [ $# -gt 0 ]; do
    #echo "+ $CMD" 1>&2 
    eval "$CMD"
    shift
  done
}

get-dotfiles()
{
    ( UA="curl/7.25.0 (x86_64-suse-linux-gnu) libcurl/7.25.0 OpenSSL/1.0.1c zlib/1.2.7 libidn/1.25 libssh2/1.4.0";
    list-dotfiles "$@" | while read -r URL; do
        NAME=${URL##*/};
        USER=${URL%"/$NAME"};
        USER=${USER##*/};
        USER=${USER#"~"};
        ( set -x;
        wget -U "$UA" -O "${NAME#.}-$USER" "$URL" );
    done )
}

get-exports() {
 (N=$#
  [ "$N" -gt 1 ] && PREFIX='$ARG: ' || PREFIX=''
  CMD='dumpbin -exports "$ARG" |sed -n "/^\\s*ordinal\\s\\+name/ { n; :lp; n; s|^\\s*[0-9]*\\s\\+\\(.*\\)|'$PREFIX'\\1|p; /^\\s*\$/! b lp; }"'
  for ARG; do
    eval "$CMD"
  done)
}

get-frags() {
 (while :; do
    case "$1" in
      -l | --left) LEFT=true; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  FS="/" BS="\\"
  EXPR="s/.*Average frag.*:\s\+\([0-9]\+\)\s\+.*/\1/"
  if [ $# -gt 1 ]; then
    "${LEFT:-false}" &&
    EXPR="$EXPR ;; s/\$/${SEP:- }\${ARG//\$FS/\$BS\$FS}/" ||
    EXPR="$EXPR ;; s/^/\${ARG//\$FS/\$BS\$FS}${SEP:-: }/"
  fi
  EXPR="/Average frag/ { $EXPR; p }"
  CMD='contig -a "$ARG" | sed -n "'$EXPR'"'
  CMD="($CMD) || return \$?"
  "${DEBUG:-false}" && echo 1>&2 "CMD='$CMD'"
  eval "for ARG; do
   $CMD
  done")
}

get-property()
{
    sed -n "/$1=/ {
   s,.*$1=,,
   /\"/! { s,\s\+.*,, }
   /^\".*\"/ { s,^\([^\"]\+\)\".*\".*,\\1, ; s,^\",, ; s,\".*,, }

  p
}"
}

get-rootfs() {
	sed -n 's,.*root=\([^ ]\+\).*,\1,p' /proc/cmdline
}

get-shortcut()
{
  (for SHORTCUT; do
  (    set -- TARGET=-t WDIR=-g ARGS=-r ICON=-i ICONOFFSET=-j DESC=-d SHOWCMD=-s
  O=
   for A; do
     O="${O:+$O
}${A%%=*}=$(readshortcut ${A##*=} "$SHORTCUT")"
     done
     echo "$O")
     done)
}

getuuid()
{
    blkid "$@" | sed -n "/ UUID=/ { s,.* UUID=\"\?,, ;; s,\".*,, ;; p }"
}

get_ext()
{
    set -- $( ( (set -- $(grep EXT.*= {find,locate,grep}-$1.sh -h 2>/dev/null |sed "s,EXTS=[\"']\?\(.*\)[\"']\?,\1," ); IFS="$nl"; echo "$*")|sed 's,[^[:alnum:]]\+,\n,g; s,^\s*,, ; s,\s*$,,';) |sort -fu);
    ( IFS=" ";
    echo "$*" )
}

get_tempdir() {
 (TEMPDIR= 
  if type reg 2>/dev/null >/dev/null; then
    TEMPDIR=`reg query 'HKCU\Environment' '/v' TEMP | sed -n 's|.*REG_SZ\s\+\(.*\)|\1|p'`
    [ -d "$TEMPDIR" ] || TEMPDIR=
  fi
  if [ -z "$TEMPDIR" ]; then
    if [ -n "$TMP" -a -d "$TMP" ]; then
      TEMPDIR="$TMP"
    elif [ -n "$TEMP" -a -d "$TEMP" ]; then
      TEMPDIR="$TEMP"
    elif [ -d "/tmp" ]; then
      TEMPDIR="/tmp"
    fi
  fi
  echo "${TEMPDIR//"\\"/"/"}")
}

git-branches()
{
 (EXPR='\, -> ,d ;; s,^remotes/,,'
  while :; do
    case "$1" in
      -l | --local) EXPR="\\,^remotes/,d ;; $EXPR"; shift ;;
      -r | --remote) EXPR="\\,^remotes/,!d ;; $EXPR"; shift ;;
      *) break ;;
    esac
  done
  EXPR="s,^. ,, ;; $EXPR"
  git branch -a | sed "$EXPR"
 )
}

git-deep-checkout() {
  (for BRANCH in $(git-branches -r "$@"); do
    git branch --track "${BRANCH##*/}" "$BRANCH"
   done)
}

git-get-branch() {
  git branch -a |sed -n 's,^\* ,,p'
}

git-get-remote() {
 (while :; do
 		case "$1" in
			-l | --list) LIST=true; shift ;;
		  -n | --name) NAME=$2; shift 2 ;; -n=* | --name=*) NAME=${1#*=}; shift ;; 
			*) break ;;
		esac
	done
	[ $# -lt 1 ] && set -- .
  [ $# -gt 1 ] && FILTER="sed \"s|^|\$DIR: |\"" || FILTER=

	EXPR="s|\\s\\+| |g"
	if [ -n "$NAME" ]; then
		EXPR="$EXPR ;; \\|^$NAME\s|!d"
	fi
	if [ "$LIST" = true ]; then
		EXPR="$EXPR ;; s| .*||"
	else
		EXPR="$EXPR ;; s|\\s*([^)]*)||"
	fi
  CMD="REMOTE=\`git remote -v 2>/dev/null"
	CMD="$CMD | sed \"$EXPR\""
	CMD="$CMD |uniq ${FILTER:+|$FILTER}\`;"
  CMD=$CMD'echo "$REMOTE"'
  for DIR; do
					(cd "${DIR%/.git}" >/dev/null &&	eval "$CMD")
		done)

}

git-set-remote()
{
  ( IFS="
"
  while :; do
    case "$1" in
      -f | --force) FORCE=true; shift ;;
      *) break ;;
    esac
  done

  gsr-arg() {
   (unset DIR NAME REMOTE
    ARG="$*"
    case "$ARG" in
      *:\ *) DIR=${ARG%%": "*}; ARG=${ARG#"$DIR: "} ;;
    esac
    if [ -n "$DIR" -a -d "$DIR" ]; then
      eval "${PRECMD}cd \"\$DIR\""
    fi
    case "$ARG" in
      *\ * | *$IFS*) NAME="${ARG%%[ $IFS]*}"; REMOTE="${ARG#*[ $IFS]}" ;;
      *) NAME="$ARG";  shift ;;
    esac
      [ -n "$DIR" ] && echo "Setting git remote '$NAME' in '$DIR' to '$REMOTE'" 1>&2
      
     eval "${PRECMD}git remote rm \"\$NAME\"" #2>/dev/null
     true

     if [ -n "$REMOTE" ]; then
       eval "${PRECMD}git remote add \"\$NAME\" \"\$REMOTE\""
     fi
   )
     #   for NAME in $(git-get-remote | awkp ); do :; done

  }
  CMD='gsr-arg $R'
  CMD="$CMD; R=\$?; [ \"\$FORCE\" = true -o \"\$R\" = 0 ] || exit \$R"

  if [ $# -le 0 ]; then
    CMD='while read -r R; do '$CMD'; done'
  else
    CMD='while [ $# -gt 0 ]; do 
      case "$1|$2|$3" in
        *": "*\|*": "*\|*": "*) R="$1"; S=1 ;;
        *": "*\|?*\|*": "*) R="$1 $2"; S=2 ;;
        *": "*\|?*\|?*)   R="$1 $2 $3"; S=3 ;;
        ?*\|?*\|*)   R="$1 $2"; S=2 ;;
        *\|*\|*)   R="$1"; S=2 ;;
      esac
      '$CMD'
      echo "Shifting by $S" 1>&2
      [ "$S" -gt "$#" ]  && S=$#
      shift ${S:-1}
      unset S
    done'
  fi
  eval "$CMD")
}

grep-e-expr()
{
	[ $# -gt 0 ] && exec <<<"$*"

	sed 's,[().*?|\\+],\\&,g ; s,\[,\\[,g ; s,\],\\],g' | implode "|" | sed 's,.*,(&),'
}

grep-e()
{
    (IFS="
";  unset ARGS;
    eval "LAST=\"\${$#}\"";
    if [ ! -d "$LAST" ]; then
        unset LAST;
    else
        A="$*"; A="${A%$LAST}";
        set -- $A;
    fi;
    while [ $# -gt 0 ]; do
        case "$1" in
            --) shift; LAST="$*"; break ;;
            -*) ARGS="${ARGS+$ARGS$IFS}$1"; shift ;;
            *) WORDS="${WORDS+$WORDS$IFS}$1"; shift ;;
        esac;
    done;
    grep -E $ARGS "$(grep-e-expr $WORDS)" ${LAST:+$LAST} )
}

grep-v-optpkgs()
{
    grep --color=auto -v -E '\-(doc|dev|dbg|extra|lite|prof|extra|manual|data|examples|source|theme|manual|demo|help|artwork|contrib)'
}

grep-v-unneeded-pkgs()
{
 (set -- common data debuginfo devel doc docs el examples fonts javadoc plugin static theme tests extras demo manual test  help info support demos

 grep -v -E "\-$(grep-e-expr "$@")(\$|\\s)")
}

grephexnums()
{
    ( IFS="|";
    unset ARGS;
    while :; do
        case "$1" in
            -*)
                ARGS="${ARGS+$ARGS$IFS}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    set -x;
    grep --color=auto --color=auto --color=auto -E $ARGS "(${*#0x})" )
}

grub-device-string()
{
    ( device_number=` disk-device-number "$1" `;
    partition_number=` disk-partition-number "$1" `;
    [ "$partition_number" ] && partition_number=$((partition_number-1));
    echo "(hd${device_number}${partition_number:+,${partition_number}})" )
}

grub2-device-string()
{
    ( device_number=` disk-device-number "$1" `;
    partition_number=` disk-partition-number "$1" `;
    echo "(hd${device_number}${partition_number:+,${partition_number}})" )
}

grub2-menuentry()
{
    ( NAME="$1";
    : ${INDENT="  "};
    shift;
    echo "menuentry '$NAME' {";
    IFS=" ";
    IFS="$IFS
";
    ENTRY="$*";
    unset LINE;
    function output-line()
    {
        [ "$LINE" ] && echo "$INDENT"$LINE;
        unset LINE
    };
    for WORD in $ENTRY;
    do
        case $WORD in
            acpi | chainloader | configfile | drivemap | echo | export | initrd | insmod | kernel | linux | linux16 | loadfont | menuentry | password | play | removed | search | set | source | submenu | timeout)
                output-line
            ;;
        esac;
        LINE="${LINE+$LINE
}$WORD";
    done;
    output-line;
    echo "}" )
}

grub2-modules-for-device()
{
    ( ARG="$1";
    [ ! -b "$ARG" ] && ARG=$(device-of-file "$ARG");
    [ ! -b "$ARG" ] && exit 2;
    FS=$(filesystem-for-device "$ARG");
    SUFFIX=${1##*/};
    SUFFIX=${SUFFIX#[hs]d[a-z]};
    DISK=${1%"$SUFFIX"};
    [ "$DISK" ] && PART_TYPE=$(partition-table-type "$DISK");
    case "$PART_TYPE" in
        msdos | mbr*)
            echo "${2}insmod part_msdos"
        ;;
        gpt* | guid*)
            echo "${2}insmod gpt"
        ;;
    esac;
    case "$FS" in
        ntfs)
            echo "${2}insmod ntfs"
        ;;
        vfat | fat32)
            echo "${2}insmod vfat"
        ;;
        fat | fat16)
            echo "${2}insmod fat"
        ;;
        hfsplus | hfs+)
            echo "${2}insmod hfsplus"
        ;;
        ext[0-9])
            echo "${2}insmod ext2"
        ;;
    esac )
}

grub2-root-for-device()
{
    ( [ ! -b "$1" ] && exit 2;
    ROOT=$(grub2-device-string "$1");
    echo "set root='$ROOT'" )
}

grub2-search-for-device()
{
    ( ARG="$1";
    [ ! -b "$ARG" ] && ARG=$(device-of-file "$ARG");
    [ ! -b "$ARG" ] && exit 2;
    BLKID=$(blkid "$ARG");
    eval "${BLKID#*": "}";
    echo "${2}search --no-floppy --fs-uuid --set" $UUID )
}

hex2chr()
{
    echo "puts -nonewline [format \"%c\" 0x$1]" | tclsh
}

hex2dec() {
 (NUM="$*"
  for N in $NUM; do
    case "$N" in
      0x*) eval "N=\$(($N))" ;;
    esac
    echo "obase=10;$N" | bc -l
  done | addprefix "${P-}")
}

hexdump_printfable()
{
    . require str;
    hexdump -C -v < "$1" | sed "s,^\([0-9a-f]\+\)\s\+\(.*\),\2 #0x\1, ; #s,0x0000,0x," | sed "s,|[^|]*|,, ; s,^, ," | sed "s,\s\+\([0-9a-f][0-9a-f]\), 0x\\1,g" | sed "s,^,printf \"$(str_repeat 16 %c)\\\n\" ,"
}

hexnums-dash()
{
    sed "s,[0-9A-Fa-f][0-9A-Fa-f],&-\\\\?,g"
}

hexnums_to_bin()
{
    ( require str;
    unset NL;
    case $1 in
        -l)
            shift;
            NL="
"
        ;;
    esac;
    IFS=" ";
    OUT=` echo "puts -nonewline \"[format $(str_repeat $#  %c) $* ]\""|tclsh `;
    echo -n "$OUT$NL" )
}

hex_to_bin()
{
    local chars=`str_to_list "$1"`;
    local bin IFS="$newline" ch;
    for ch in $chars;
    do
        case $ch in
            0)
                bin="${bin}0000"
            ;;
            1)
                bin="${bin}0001"
            ;;
            2)
                bin="${bin}0010"
            ;;
            3)
                bin="${bin}0011"
            ;;
            4)
                bin="${bin}0100"
            ;;
            5)
                bin="${bin}0101"
            ;;
            6)
                bin="${bin}0110"
            ;;
            7)
                bin="${bin}0111"
            ;;
            8)
                bin="${bin}1000"
            ;;
            9)
                bin="${bin}1001"
            ;;
            a | A)
                bin="${bin}1010"
            ;;
            b | B)
                bin="${bin}1011"
            ;;
            c | C)
                bin="${bin}1100"
            ;;
            d | D)
                bin="${bin}1101"
            ;;
            e | E)
                bin="${bin}1110"
            ;;
            f | F)
                bin="${bin}1111"
            ;;
        esac;
    done;
    echo "$bin"
}

hex_to_dec()
{
    eval 'echo $((0x'${1%% *}'))'
}

hsl()
{
    ( h=$(( $1 * 360 / 255 ));
    s=$2 l=$3;
    while [ "$h" -lt 0 ]; do
        h=$((h+360));
    done;
    while [ "$h" -gt 360 ]; do
        h=$((h-360));
    done;
    if [ "$h" -lt 120 ]; then
        rsat=$(( (120-h) ));
        gsat=$(( h ));
        bsat=$(( 0 ));
    else
        if [ "$h" -lt 240 ]; then
            rsat=$(( 0 ));
            gsat=$(( (240-h) ));
            bsat=$(( (h-120) ));
        else
            rsat=$(( (h-240) ));
            gsat=$(( 0 ));
            bsat=$(( (360-h) ));
        fi;
    fi;
    rsat=$(min $rsat 60);
    gsat=$(min $gsat 60);
    bsat=$(min $bsat 60);
    echo $rsat $gsat $bsat;
    rtmp=$(( 2*${s}*${rsat}+(255-s) ));
    gtmp=$(( 2*${s}*${gsat}+(255-s) ));
    btmp=$(( 2*${s}*${bsat}+(255-s) ));
    echo $rtmp $gtmp $btmp;
    if [ "$l" -lt 255 ]; then
        r=$(( l*rtmp/65535 ));
        g=$(( l*gtmp/65535 ));
        b=$(( l*btmp/65535 ));
    else
        r=$(( ((255-l)*rtmp+2*l)/65535 ));
        g=$(( ((255-l)*gtmp+2*l-255)/65535 ));
        b=$(( ((255-l)*btmp+2*l-255)/65535 ));
    fi;
    echo $r $g $b )
}

http_head()
{
    ( HOST=${1%%:*};
    PORT=80;
    TIMEOUT=30;
    if [ "$HOST" != "$1" ]; then
        PORT=${1#$HOST:};
    fi;
    if type curl > /dev/null 2> /dev/null; then
        curl -q --head "http://$HOST:$PORT$2";
    else
        if type lynx > /dev/null 2> /dev/null; then
            lynx -head -source "http://$HOST:$PORT$2";
        else
            {
                echo -e "HEAD ${2} HTTP/1.1\r\nHost: ${1}\r\nConnection: close\r\n\r";
                sleep $TIMEOUT
            } | nc $HOST $PORT | sed "s/\r//g";
        fi;
    fi )
}

id3()
{
    $ID3V2 -l "$@" | sed "
	s,^\([^ ]\+\) ([^:]*):\s\?\(.*\),\1=\2,
	 s,.* info for s\?,,
	/:$/! { /^[0-9A-Z]\+=/! { s/ *\([^ ]\+\) *: */\n\1=/g; s,\s*\n\s*,\n,g; s,^\n,,; s,\n$,,; s,\n\n,,g; }; }" | sed "/:$/ { p; n; :lp; N; /:\$/! { s,\n, ,g;  b lp; }; P }"
}

id3dump()
{
    ( IFS="
	";
    unset FLAGS;
    while :; do
        case "$1" in
            -*)
                FLAGS="${FLAGS+$FLAGS
	}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
		id3v2 $FLAGS  -l "$@" | sed -n 's, ([^:]*)\(\[[^]]*\]\)\?:\s\+,: , ;; s,^\([[:upper:][:digit:]]\+\):,\1:,p'
		)
}

id3get()
{
    ( id3dump "$1" 2>&1 | grep "^$2" | sed 's,^[^:=]*[:=]\s*,,' )
}

imagedate()
{
				(
				case "$1" in
								 -u | --unix*) UT=true ; shift ;;
				 esac
				N=$#
				 for ARG; do
				TS=$(exiv2 pr "$ARG" 2>&1| sed -n '/No\sExif/! s,.*timestamp\s\+:\s\+,,p' | sed 's,\([0-9][0-9][0-9][0-9]\):\([0-9]\+\):\([0-9][0-9]\),\1/\2/\3,')
				[ "$UT" = true ] && TS=$(date2unix "$TS" 2>/dev/null)
				O="$TS"

				[ $N -gt 1 ] && O="$ARG:$O"
				echo "$O"
		done)
}

imatch_some()
{
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}

implode()
{
 (unset DATA SEPARATOR;
  SEPARATOR="$1"; shift
  CMD='DATA="${DATA+$DATA$SEPARATOR}$ITEM"'
  if [ $# -gt 0 ]; then
    CMD="for ITEM; do $CMD; done"
  else
    CMD="while read -r ITEM; do $CMD; done"
  fi
  eval "$CMD"
  echo "$DATA")
}

importlibs()
{
    local lib IFS="|";
    for lib in $__LIBS__;
    do
        if ! source $shlibdir/$lib.sh 2> /dev/null; then
            echo "Error loading $lib.sh" 1>&2;
            return $?;
        fi;
    done
}

inc()
{
    expr "$1" + "${2-1}"
}

incv()
{
    eval "$1=\`expr \"\${$1}\" + \"${2-1}\"\`"
}

index-dir()
{ 
    [ -z "$*" ] && set -- .;
    ( [ "$(uname -m)" = "x86_64" ] && : ${R64="64"};
    for ARG in "$@";
    do
        ( cd "$ARG";
        if ! test -w "$PWD"; then
            echo "Cannot write to $PWD ..." 1>&2;
            exit;
        fi;
        echo "Indexing directory $PWD ..." 1>&2;
        TEMP=`mktemp "/tmp/XXXXXX.list"`;
        trap 'rm -f "$TEMP"; unset TEMP' EXIT;
        ( if type list-r${R64} 2> /dev/null > /dev/null; then
            list-r${R64} 2> /dev/null;
        else
            list-recursive;
        fi ) > "$TEMP";
        ( install -m 644 "$TEMP" "$PWD/files.list" && rm -f "$TEMP" ) || mv -f "$TEMP" "$PWD/files.list";
        wc -l "$PWD/files.list" 1>&2 );
    done )
}

index-of()
{
    io="$1";
    shift;
    s="$*";
    for-each-char 'if [ "$io" = "$c" ]; then echo "$i"; return 0; fi' "$s"
}

index-tar()
{
    ( while :; do
      case "$1" in
         -s | --save ) SAVE=true; shift ;;
         -d | --debug ) DEBUG=true; shift ;;
         *) break ;;
         esac
         done

FILTERCMD='sed "s,^\./,,"'
if [ $# -gt 1 ]; then
        FILTERCMD=${FILTERCMD:+$FILTERCMD'|'}'sed "s|^|$ARG:|"';
    else
        unset FILTERCMD;
    fi
    [ "$SAVE" = true ] && OUTPUT="\${ARG%.tar*}.list"

    CMD="tar -tf \"\$ARG\" 2>/dev/null ${FILTERCMD+|$FILTERCMD}${OUTPUT:+>$OUTPUT}"
    [ "$DEBUG" = true ] && DBG="echo \"tar -tf \$ARG${OUTPUT:+ >$OUTPUT}\"; "
   eval "for ARG; do $DBG eval \"\$CMD\" ; done")
}

index()
{
    ( INDEX=`expr ${1:-0} + 1`;
    shift;
    echo "$*" | cut -b"$INDEX" )
}

indexarg()
{
    ( I="$1";
    shift;
    eval echo "\${@:$I:1}" )
}

index_of()
{
    ( needle="$1";
    index=0;
    while [ "$#" -gt 1 ]; do
        shift;
        if [ "$needle" = "$1" ]; then
            echo "$index";
            exit 0;
        fi;
        index=`expr "$index" + 1`;
    done;
    exit 1 )
}

inputf()
{
    local __line__ __cmds__;
    __line__=$IFS;
    __cmds__="( set -- \$__line__; $*; )";
    IFS="$__line__";
    while read __line__; do
        eval "$__cmds__";
    done
}

inst-slackpkg()
{
    ( . require.sh;
    require array;
    while :; do
        case "$1" in
            -a)
                ALL=true;
                shift
            ;;
            -f)
                FILE=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    INSTALLED=;
    EXPR="$(grep-e-expr "$@")";
    [ "$FILE" = true ] && EXPR="/$EXPR[^/]*\$";
    PKGS=` grep --color=auto -H -E "$EXPR" $([ "$PWD" = "$HOME" ] && ls -d slackpkg*)  ~/slackpkg* | sed 's,.*:/,/, ; s,/slackpkg[^./]*\.list:,/,'`;
    if [ -z "$PKGS" ]; then
        echo "No such package $EXPR" 1>&2;
        exit 2;
    fi;
    set -- $PKGS;
    IFS="
$IFS";
    if [ "$ALL" != true -a $# -gt 1 ]; then
        echo "Multiple packages:" 1>&2;
        echo "$*" 1>&2;
        exit 2;
    fi;
    for PKG in "$@";
    do
        NAME=${PKG##*/};
        NAME=${NAME%.t?z};
        if ! array_isin INSTALLED "$NAME"; then
            echo "Installing $PKG ..." 1>&2;
            ( echo;
            installpkg "$PKG" 2>&1;
            echo ) >> install.log;
            array_push_unique INSTALLED "$NAME";
        else
            echo "Package $PKG already installed" 1>&2;
        fi;
    done )
}

in_path()
{
    local dir IFS=:;
    for dir in $PATH;
    do
        ( cd "$dir" 2> /dev/null && set -- $1 && test -e "$1" ) && return 0;
    done;
    return 127
}

is-absolute()
{
    ! is-relative "$@"
}

is-mounted()
{
    isin "$1" $(mounted-devices)
}

is-relative()
{
    case "$1" in
        /*)
            return 1
        ;;
        *)
            return 0
        ;;
    esac
}

is-upx-packed()
{
    list-upx "$1" | grep --color=auto --color=auto --color=auto -q "\->.*$1"
}

isin()
{
    ( needle="$1";
    while [ "$#" -gt 1 ]; do
        shift;
        test "$needle" = "$1" && exit 0;
    done;
    exit 1 )
}

iso-extract()
{
    ( NAME=`basename "$1" .iso`;
    DEST=${2:-"$NAME"};
    7z x -o"$DEST" "$1" )
}

isodate()
{
    date +%Y%m%d
}

is_binary()
{
    case `file - <$1` in
        *text*)
            return 1
        ;;
        *)
            return 0
        ;;
    esac
}

is_interactive()
{
    test -n "$PS1"
}

is_object()
{
    case `file - <$1` in
        *ELF* | *executable*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

is_pattern()
{
    case "$*" in
        *'['*']'* | *'*'* | *'?'*)
            return 0
        ;;
    esac;
    return 1
}

is_true()
{
    case "$*" in
        true | ":" | "${FLAGS_TRUE-0}" | yes | enabled | on)
            return 0
        ;;
    esac;
    return 1
}

is_url()
{
    case $1 in
        *://*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

is_var()
{
    case $1 in
        [!_A-Za-z]* | *[!_0-9A-Za-z]*)
            return 1
        ;;
    esac;
    return 0
}

killall-w32()
{
    ( IFS="
	 ";
    PIDS=$(IFS="|"; ps.exe -aW |grep -i -E "($*)" | awk '{ print $1 }');
    kill.exe -f $PIDS )
}

lastarg()
{
    ( eval echo "\${$#}" )
}

launch-x11() {
 (IFS=" "
  CMD="$*"

  : ${DISPLAY:=":0"}

  export DISPLAY
  xhost +

  eval "$CMD" 2>/dev/null >/dev/null &)
}

len()
{
    eval "echo \${#$1}"
}

lftpls()
{
    ( lftp "$1" -e "find $1/; exit" )
}

linedelay()
{
    unset o;
    while read i; do
        test "${o+set}" = set && echo "$o";
        o=$i;
    done;
    test "${o+set}" = set && echo "$o"
}

lines()
{
    for ARG in "$@";
    do
        N=$( set -- $ARG; (xzcat "$1" || bzcat "$1" || zcat "$1" || cat "$1") 2>/dev/null | wc -l);
        test "$#" -gt 1 && printf "%10d %s\n" $N $ARG || echo "$N";
    done
}

link-mpd-music-dirs()
{
    ( : ${DESTDIR=/var/lib/mpd/music};
    mkdir -p "$DESTDIR";
    chown mpd:mpd "$DESTDIR";
    for ARG in "$@";
    do
        ( NAME=$(echo "$ARG" |sed " s,^/mnt,, ; s,^/media,,g; s,/,-,g; s,^-*,, ; s,-*$,,");
        ( set -x;
        ln -svf "$ARG" "$DESTDIR"/"$NAME" ) );
    done )
}

list-7z() {
 (while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
	  [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
	fi
  }
  output_line() {
	case "$PREV" in
	  "$DN"/* | "$DN/" | "$DN") ;;
	  *) : echo "$DN/" ;;
	  esac
	#    [ -z "$NAME" ] && unset F FP
	if [ "$FN" = "$PREV/" ]; then
	  PREV="$PREV/"
	fi
	case "$PREV" in
	  */) 
		case "$FN" in
		  $PREV/*) ;;
		  *) unset PREV ;;
		esac
	  ;;
	  esac
	if [ -n "PREV" -a "$FN" != "$PREV" -a "$FN" != "$PPREV" ]; then
	  case "$PREV" in 
	    */) ;;
	    *)
	    DIR="${PREV}"
	      while :; do
	        [ "$DIR" = "${DIR%/*}" ] && break
	        DIR="${DIR%/*}"
	       #echo "DIR='$DIR' PREVDIR='$PREVDIR'" 1>&2
	      if [ -z "$PREVDIR" -o "${PREVDIR#$DIR/}" = "$PREVDIR" ]; then
	       #[ -n "$PREVDIR" ] && output "$PREVDIR"
	       PREVDIR="$DIR/"
	      fi
	      
	      case "$DIR" in
	        ${PREVDIR%/}/*) continue ;;
	      esac	      
	      case "${PREVDIR%/}" in
	        ${DIR}/*) continue ;;
	      esac
	      [ "$DIR/" != "$PREVDIR" ] && output "$DIR/"
	        case "${PREVDIR%/}" in
	          $DIR | $DIR/*) ;;
	          *) PREVDIR="$DIR/" ;;
	        esac
	      done	    
	     ;;
	  esac
	  output "$PREV"
	fi   
	PPREV="$PREV"
	if [ -n "$FN" -a "$FN" != "$PREV" ]; then
	  #output "$FN"
	  PREV="$FN"
	fi
	case "$PREV" in
	  */) PREVDIR="$PREV" ;;
	esac
	[ -z "$NAME" ] && unset A F FP PSZ SZ T FN
  }
  while [ $# -gt 0 ]; do
   (B=${1##*/}
    case "$1" in 
      *://*) INPUT="wget -q -O - \"\$1\"" ;;
      *) ARCHIVE=$1  ;;
    esac
    case "$1" in 
      *.t?z | *.tbz2)
        T=${1%.t?z}
        T=${T%.tbz2} 
        T=$T.tar
        INPUT="${INPUT:+$INPUT | }7z x${INPUT:+ -si\"${1}\"} -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si\"${T}\"";  CMD="7z l -slt $OPTS"
        ;;
      *.tar.*) INPUT="${INPUT:+$INPUT | }7z x -so${ARCHIVE+ \"$ARCHIVE\"}"; OPTS="${OPTS:+$OPTS }-si\"${B%.*}\"";  CMD="7z l -slt $OPTS" ;;
      *) CMD="7z l -slt $OPTS ${ARCHIVE+\"$ARCHIVE\"}" ;;
    esac
    if [ -n "$INPUT" ]; then
      CMD="${INPUT+$INPUT | }$CMD"
      OPTS="$OPTS${IFS:0:1}-si\"${1##*/}\""
    fi 
    ( #echo "CMD: $CMD" 1>&2 
     eval "($CMD; echo) 2>/dev/null" ) | 
    { IFS=" "; unset PREV; while read -r NAME EQ VALUE; do
        case "$NAME" in
          "Type") T=${VALUE}; continue ;;
          "Path") F=${VALUE//"\\"/"/"}; continue ;;
          "Folder") [ "$VALUE" = + ] && FP="/"; continue       ;;
          "Attributes") A=${VALUE}; continue ;;
          "Size") SZ=${VALUE}; continue ;;
          "Packed Size") PSZ=${VALUE}; continue ;;
          "----------") T=; continue ;; 
          "Block"|"Blocks"|"CRC"|"Encrypted"|"Method"|"Modified"|"Solid") continue ;;
  "--" | \
  "7-Zip" | "Headers" | "Listing" | "Packed" | "Physical") continue ;;
          *) #echo "NAME='$NAME'" 1>&2
            ;;
        esac
        [ -n "$T" ] && continue
        case "$A" in
          D*) FP="/" ;;
        esac
        FN="$F$FP"
        DN="${F%/*}"
        output_line 
      done
      output_line 
    }
    )
    shift
  done)
}

list-broken-links() {
  (for ARG; do
    DIR=`dirname "$ARG"`
    BASE=`basename "$ARG"`

    TARGET=$(cd "$DIR"; readlink "$BASE")
    
    ABS="$DIR/$TARGET"

    test -e "$ABS" || echo "$ARG"
   done)
}

list-deb() { 
 (trap 'exit 1' INT 
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
    fi
  }
	for ARG in "$@"; do
   (set -e
	  trap 'rm -rf "$TEMP"' EXIT 
    TEMP=$(mktemp -d "$PWD/${0##*/}-XXXXXX")
    mkdir -p "$TEMP"
		case "$ARG" in
			*://*) 
			  if type wget >/dev/null 2>/dev/null; then
				  wget -P "$TEMP" -q "$ARG"
				elif type curl >/dev/null 2>/dev/null; then
					curl -s -k -L -o "$TEMP/${ARG##*/}" "$ARG"
				elif type lynx >/dev/null 2>/dev/null; then
					lynx -source >"$TEMP/${ARG##*/}" "$ARG"
				fi || exit $?
				DEB="${ARG##*/}"
			;;
			*) DEB=$(realpath "$ARG") ;;
		esac
    cd "$TEMP"
		set -- $( ("${AR-ar}" t "$DEB" || list-7z "$DEB") 2>/dev/null |uniq |grep "data\.tar\.")
		if [ $# -le 0 ]; then
			exit 1
		fi
		case "$1" in
			*.bz2) TAR_ARGS="-j" ;;
			*.xz) TAR_ARGS="-J" ;;
			*.gz) TAR_ARGS="-z" ;;
			*.tar) TAR_ARGS="" ;;
		esac

   ( { "${AR-ar}" x "$DEB" "$1"; test -e "$1"; } ||
		7z x "$DEB" "$1") 2>/dev/null
    "${TAR-tar}" $TAR_ARGS -t -f "$1" 2>/dev/null | while read -r LINE; do
			case "$LINE" in
				./) LINE="/" ;;
				./?*) LINE="${LINE#./}" ;;
			esac
      output "$LINE"
		done) ||
		output "ERROR" 1>&2 
	done)
}

list-dotfiles()
{
    ( for ARG in "$@";
    do
        dlynx.sh "http://dotfiles.org/.${ARG#.}" | grep --color=auto --color=auto --color=auto --color=auto "/.${ARG#.}\$";
    done )
}

list-files()
{
    ( OUTPUT=">";
    OUTFILE=".files.file.tmp";
    while :; do
        case "$1" in
            -v)
                OUTPUT="| tee ";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# = 0 ] && set .;
    NL="
";
    FILTER="xargs -d \"\$NL\" file | sed \"s|^\.\/|| ;; s|:\s\+|: |\" ${OUTPUT}\"\${OUTFILE}\"";
    for ARG in "$@";
    do
        ( cd "$ARG";
        find . -xdev -not -type d | eval "$FILTER";
        mv -f .files.file.tmp files.file;
        echo "Created $PWD/files.file" 1>&2 );
    done )
}

list-lastitem()
{
    sed -n '$p'
}

list-mediapath() {
 (while :; do
		case "$1" in
		  -b|-c|-d|-e|-f|-g|-h|-k|-L|-N|-O|-p|-r|-s|-x) FILTER="${FILTER:+$FILTER | }filter-test $1"; shift ;;
		  -m|--mixed|-M|--mode|-u|--unix|-w|--windows|-a|--absolute|-l|--long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1"; shift ;;
			-*) OPTS="${OPTS:+$OPTS }$1"; shift ;;
			--) shift; break ;;
			*) break ;;
			esac
	done
	for ARG; do CMD="${CMD:+$CMD; }ls -1 -d $OPTS -- $MEDIAPATH/${ARG#/} 2>/dev/null"; done
	
	[ -n "$PATHTOOL_OPTS" ] && CMD="$PATHTOOL ${PATHTOOL_OPTS:--m} \$($CMD)"
	#CMD="for ARG; do $CMD; done"
	[ -n "$FILTER" ] &&	 CMD="($CMD) | $FILTER"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
	eval "$CMD")
}

list-nolastitem()
{
    sed '$d'
}

list-path()
{
  (IFS=":"; find $PATH -maxdepth 1 -mindepth 1 -not -type d)
}

list-rar() {
 (while :; do 
    case "$1" in
      -*) OPTS="${OPTS:+$OPTS${IFS:0:1}}$1"; shift ;;
      *) break ;;
    esac
  done
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
	  [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
	fi
  }
  for ARG; do
   (IFS="/\\"
    LINENO=0
    HEADER_OK="false"
    unrar v "$ARG" | while read -r LINE; do
      LINENO=$((LINENO + 1))
      case "$LINE" in
        -------------------------------------------------------------------------------*)
          HEADER_OK="true"
          continue
        ;;
        "  "*)
          continue
        ;;
      esac
      "$HEADER_OK" || continue
        
      LINE=${LINE#" "}
      LINE=${LINE%$'\r'}
      #LINE=${LINE//"\\"/"/"}
      
      output $LINE
    done)
  done)
}

list-recursive()
{
    ( NL="
";
    unset ARGS;
    while :; do
        case "$1" in
            -s | -save)
                SAVE=true;
                shift
            ;;
            -a | -o | -maxdepth | -amin | -atime | -cnewer | -fstype | -group | -iname | -iwholename | -links | -mmin | -name | -path | -wholename | -uid | -user | -fprintf | -fprint | -exec | -ok | -execdir)
                ARGS="${ARGS:+$ARGS$NL}$1${NL}$2";
                shift 2
            ;;
            -print | -and | -follow | -depth | -mount | --version | -ignore_readdir_race | -N | -false | -nogroup | -readable | -executable | -type | -delete | -print | -prune)
                ARGS="${ARGS:+$ARGS$NL}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# = 0 ] && set .;
    for ARG in "$@";
    do
        ( cd "$ARG";
        CMD='find . $ARGS -xdev  | while read -r FILE; do test -d "$FILE" && echo "$FILE/" || echo "$FILE"; done | sed "s|^\.\/||"';
        [ "$SAVE" = true ] && CMD="$CMD | { tee .${FILENAME:-files}.${TMPEXT:-tmp}; mv -f .${FILENAME:-files}.${TMPEXT:-tmp} ${FILENAME:-files}.${EXT:-list}; echo \"Created \$PWD/${FILENAME:-files}.${EXT:-list}\" 1>&2; }";
        eval "$CMD" );
    done )
}

list-rpm() { 
 (NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
    fi
  }
	LOG="$PWD/$(basename "$0" .sh).log"
	exec_cmd() {
	 (
	  echo "CMD: $@" 1>&2
	  echo "CMD: $@" >>"$LOG"
	  exec "$@")
	}
	for ARG in "$@"; do
   (set -e
	  trap 'rm -rf "$TEMP"' EXIT QUIT TERM INT
    TEMP=$(mktemp -d "$PWD/${0##*/}-XXXXXX")
    mkdir -p "$TEMP"
		case "$ARG" in
			*://*) 
			  if type wget >/dev/null 2>/dev/null; then
				  exec_cmd wget -P "$TEMP" -q "$ARG"
				elif type curl >/dev/null 2>/dev/null; then
					exec_cmd curl -s -k -L -o "$TEMP/${ARG##*/}" "$ARG"
				elif type lynx >/dev/null 2>/dev/null; then
					exec_cmd lynx -source >"$TEMP/${ARG##*/}" "$ARG"
				fi || exit $?
				RPM="${ARG##*/}"
			;;
			*) RPM=$(realpath "$ARG") ;;
		esac
    cd "$TEMP"
		set -- $( (    7z l "$RPM" |sed -n "\$d; /^----------/ { n; /^------------------/ { :lp; \$! { d; b lp; }; } ; /^-/! { / files\$/! s|^...................................................  ||p }; }"  ||
		(exec_cmd "${RPM2CPIO-rpm2cpio}" >/dev/null; R=$?; [ $R -eq 0 ] && echo "$(basename "$RPM" .rpm).cpio"; exit $R) ) 2>/dev/null |uniq |grep "\\.cpio\$")
		if [ $# -le 0 ]; then
			exit 1
		fi
		CPIOCMD="exec_cmd cpio -t 2>/dev/null"
		case "$1" in
			*.bz2) CPIOCMD="bzcat | $CPIOCMD" ;;
			*.xz) CPIOCMD="xzcat | $CPIOCMD" ;;
			*.gz) CPIOCMD="zcat | $CPIOCMD" ;;
			*.cpio) ;;
		esac
		((set -x; exec_cmd 7z x -so "$RPM" "$1" ) ||
	 { exec_cmd "${RPM2CPIO-rpm2cpio}" <"$RPM"; }
		 ) 2>/dev/null |
    eval "$CPIOCMD" | while read -r LINE; do
			case "$LINE" in
				./) LINE="/" ;;
				./?*) LINE="${LINE#./}" ;;
			esac
      output "$LINE"
		done) ||
		output "ERROR" 1>&2 
	done)
}

list-slackpkgs()
{
    ( [ -z "$*" ] && set -- .;
    for ARG in "$@";
    do
        find "$ARG" -type f -name "*.t?z";
    done | sed 's,^\./,,' )
}

list-subdirs()
{
    ( find ${@-.} -mindepth 1 -maxdepth 1 -type d | sed "s|^\./||" )
}

list-tolower()
{
    tr [:{upper,lower}:]
}

list-toupper()
{
    tr [:{lower,upper}:]
}

list-upx()
{
    upx -l "$@" 2>&1 | sed '1 { :lp; N; /^\s*--\+/! b lp; d; }' | sed '$ { /[0-9]\sfiles\s\]$/d; } ; /^\s*[- ]\+$/d'
}

list() {
 (for ARG; do
    echo "$ARG"
  done)
}

locate-filename()
{
    ( IFS="
 ";
    unset TEST_ARGS;
    while :; do
        case "$1" in
            -i)
                IGNORE_CASE=true;
                shift
            ;;
            -r)
                REGEXP=true;
                shift
            ;;
            -a | -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -s | -u | -w | -x)
                TEST_ARGS="${TEST_ARGS:+$TEST_ARGS
}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    LOCATE_ARGS=;
    if [ "$IGNORE_CASE" = true ]; then
        LOCATE_ARGS="${LOCATE_ARGS:+$LOCATE_ARGS
}-i" GREP_ARGS="${GREP_ARGS:+$GREP_ARGS
}-i";
    fi;
    for EXPR in "$@";
    do
        if [ "$REGEXP" != true ]; then
            EXPR=${EXPR//"."/"\\."};
            EXPR=${EXPR//"?"/"."};
            EXPR=${EXPR//"*"/"[^/]*"};
            case "$EXPR" in
                *"[^/]*")

                ;;
                *)
                    EXPR="$EXPR\$"
                ;;
            esac;
            case "$EXPR" in
                "[^/]*"*)

                ;;
                *)
                    EXPR="^$EXPR"
                ;;
            esac;
            REGEXP=true;
        fi;
        if [ "$REGEXP" = true ]; then
            case "$EXPR" in
                *\$)

                ;;
                *)
                    EXPR="${EXPR%"[^/]*"}[^/]*\$"
                ;;
            esac;
            case "$EXPR" in
                ^*)
                    EXPR="/${EXPR#^}"
                ;;
            esac;
            EXPR=${EXPR//'.*'/'[^/]*'};
        fi;
        CMD='(set -x; locate $LOCATE_ARGS -r "$EXPR") ';
        if [ -n "$TEST_ARGS" ]; then
            CMD="$CMD | filter-test \$TEST_ARGS";
        fi;
        CMD="$CMD | (set -x ; grep \$GREP_ARGS \"\${EXPR#/}\") ";
        eval "$CMD";
    done )
}

ls-dirs()
{
    ( [ -z "$@" ] && set -- .;
    for ARG in "$@";
    do
        ls --color=auto -d "$ARG"/*/;
    done ) | sed 's,^\./,,; s,/$,,'
}

ls-files()
{
    ( [ -z "$@" ] && set -- .;
    for ARG in "$@";
    do
        ls --color=auto -d "$ARG"/*;
    done ) | filter-test -f| sed 's,^\./,,; s,/$,,'
}

unalias ls-l 2>/dev/null
ls-l()
{
    ( I=${1:-6};
    set --;
    while [ "$I" -gt 0 ]; do
        set -- "ARG$I" "$@";
        I=`expr $I - 1`;
    done;
    IFS=" ";
    CMD="while read  -r $* P; do  echo \"\${P}\"; done";
    echo "+ $CMD" 1>&2;
    eval "$CMD" )
}

lsof-win()
{
#  (for PID in $(ps -aW | sed 1d |awkp 1); do
#    handle -p "$PID" |sed "1d;2d;3d;4d;5d; s|^|$PID\\t|"
#  done)
 (while :; do
    case "$1" in
      -p) PIDS="${PIDS+$PIDS$IFS}$2"; shift 2 ;;
      -p=*) PIDS="${PIDS+$PIDS$IFS}${1#*=}"; shift ;;
      -p*) PIDS="${PIDS+$PIDS$IFS}${1#-p}"; shift ;;
      *) break ;;
    esac
  done
  if [ -n "$PIDS" ]; then
    CMD='for PID in $PIDS; do EXE=$(proc-by-pid $PID); echo "${EXE##*[\\/]}.exe pid: $PID"; handle -p $PID; done'
  else
    CMD='handle -a'
  fi
  eval "$CMD" 2>&1 | { 
  TAB="	"
  CR=""
  IFS="$CR"
  while read -r LINE; do
    case "$LINE" in
      *"pid: "*) 
        LSOF_PID=${LINE##*"pid: "}
        LSOF_PID=${LSOF_PID%%" "*}
        EXE=${LINE%%" "*}
        EXE=${EXE%.[Ee][Xx][Ee]}
      ;;
      "" | "Copyright (C) 1997-2014 Mark Russinovich" | "Handle v4.0" | "Sysinternals - www.sysinternals.com") continue ;;

      *) printf "%-10s %5d %s\n" "$EXE" "$LSOF_PID" "$LINE" ;;
    esac
  done; })
}

make-slackpkg()
{
    (IFS="
"
    require str

     : ${OUTDIR="$PWD"};
    [ -z "$1" ] && set -- .;
    ARGS="$*"
IFS=";, $IFS"
   set -- $EXCLUDE '*~' '*.bak' '*.rej' '*du.txt' '*.list' '*.log' 'files.*' '*.000' '*.tmp'
   IFS="
"
  EXCLUDELIST="{$(set -- $(for_each str_quote "$@"); IFS=','; echo "$*")}"
    for ARG in $ARGS;
    do
        test -d "$ARG";
        cmd="(cd \"$ARG\" >/dev/null; tar --exclude=${EXCLUDELIST} -cv --no-recursion \$(echo .; find install/ 2>/dev/null; find * -not -wholename 'install*'  |sort ) |xz -0 -f  -c  > \"$OUTDIR/\${PWD##*/}.txz\")";
        echo + "$cmd" 1>&2;
        eval "$cmd";
    done
    )
}

make_arith()
{
    echo '$(('"$@"'))'
}

map()
{
    from=$1 to=$2;
    shift;
    while shift && [ "$#" -gt 0 ]; do
        if var_isset "$from$1"; then
            var_set "$to$1" "`var_get "$from$1"`";
        fi;
    done;
    unset -v from to
}

match-devices()
{
    ( EXPR="$*";
    foreach-partition 'case $DEV:$TYPE:$UUID:$LABEL in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV: TYPE=\"$TYPE\" UUID=\"$UUID\" LABEL=\"$LABEL\"" ;; esac' )
}

match-mounted()
{
    ( EXPR="$*";
    foreach-mount 'case $DEV:$MNT:$TYPE:$OPTS in
$EXPR:*:*:* | *:$EXPR:*:* | *:*:$EXPR:* | *:*:*:$EXPR) echo "$DEV $MNT $TYPE $OPTS $A $B" ;; esac' )
}

match()
{
 (EXPR="$1"; shift
  CMD='case $LINE in
  $EXPR) echo "$LINE" ;;
esac'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD")
}

matchall()
{
    ( STR="$1";
    shift;
    while [ $# -gt 0 ]; do
        case "$STR" in
            $1)

            ;;
            *)
                exit 1
            ;;
        esac;
        shift;
    done;
    exit 0 )
}

matchany()
{
    ( STR="$1";
    shift;
    set -o noglob;
    for EXPR in "$@";
    do
        case "$STR" in
            *$EXPR*)
                exit 0
            ;;
            *)

            ;;
        esac;
    done;
    exit 1 )
}

match_some()
{
    eval "while shift
  do
  case \"\$1\" in
    $1 ) return 0 ;;
  esac
  done
  return 1"
}

max()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -gt "$i" ] && i="$1";
    done;
    echo "$i" )
}

mime()
{
    local mime="$(decompress "$1" | bheader 8 | file -bi -)";
    echo ${mime%%[,. ]*}
}

min()
{
    ( i="$1";
    while [ $# -gt 1 ]; do
        shift;
        [ "$1" -lt "$i" ] && i="$1";
    done;
    echo "$i" )
}

minfo()
{
    #timeout ${TIMEOUT:-10} \
   (CMD='mediainfo "$ARG" 2>&1'
    [ $# -gt 1 ] && CMD="$CMD | addprefix \"\$ARG:\""
    CMD="for ARG; do $CMD; done"
    eval "$CMD")  | sed '#s|\s\+:\s\+|: | ; s|\s\+:\([^:]*\)$|:\1| ; s| pixels$|| ; s|: *\([0-9]\+\) \([0-9]\+\)|: \1\2|g '
}

mktempdata()
{
    local path prefix="${tmppfx-${myname-${0##*/}}}" file;
    if [ "$#" -gt 1 ]; then
        path=$1;
        shift;
    else
        unset path;
    fi;
    if [ "$#" -gt 1 ]; then
        local prefix=$1;
        shift;
    fi;
    file=`command ${path:-"-t"} "${path:+$path/}${prefix#-}${path:-.XXXXXX}"`;
    if [ -n "$*" ]; then
        echo "$*" > $file;
    fi;
    echo "$file"
}

mktempdir()
{
    local prefix=${2:-${tmppfx:-${myname:-${0##*/}}}};
    local path=${1:-${tmpdir:-"/tmp"}};
    command mktemp -d ${path:-"-t" }"${path:+/}${prefix#-}.XXXXXX"
}

mktempfile() {
   (prefix=${2-${tmppfx-${MYNAME-${0##*/}}}};
    path=${1-${TEMP-"/tmp"}};
    tempfile=${path}/${prefix#-}.${RANDOM}
    rm -f "$tempfile"
    echo -n >"$tempfile"
    echo "$tempfile")
}

mkuuid() {
   printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM"
}

mkzroot()
{
    ( IFS="$IFS " TEMPTAR=/tmp/mkzroot$$.tar;
    trap 'rm -vf "$TEMPTAR"' EXIT INT QUIT;
    EXCLUDE="*~ *.tmp *mnt/* *.log *cache/*";
    CMD='tar --one-file-system --exclude={$(IFS=", $IFS"; set -f ; set -- $EXCLUDE;  echo "$*")} -C /root -cf "$TEMPTAR" .';
    eval "echo \"+ $CMD\" 1>&2";
    eval "$CMD";
    DEST=$(ls -d ` mountpoints /pmagic/pmodules ` 2>/dev/null);
    for DIR in $DEST;
    do
        ( CMD="xz -1  -c <\"\$TEMPTAR\"  >\"\$DIR/zroot.xz\"";
        eval "echo \"+ $CMD\" 1>&2";
        eval "$CMD" );
    done )
}

mminfo()
{
    ( for ARG in "$@";
    do
        minfo "$ARG" | sed -n "s,^\([^:]*\):\s*\(.*\),${2:+$ARG:}\1=\2,p";
    done | sed 's,\s\+=,=,')
}

modules()
{
    local abs="no" ext="no" dir modules= IFS="
";
    require "fs";
    while :; do
        case $1 in
            -a)
                abs="yes"
            ;;
            -e)
                ext="yes"
            ;;
            -f)
                abs="yes" ext="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    if test "$abs" = yes; then
        fs_recurse "$@";
    else
        for dir in "${@-$shlibdir}";
        do
            ( cd "$dir" && fs_recurse );
        done;
    fi | {
        set --;
        while read module; do
            case $module in
                *.sh | *.bash)
                    if test "$ext" = no; then
                        module="${module%.*}";
                    fi;
                    if ! isin "$module" "$@"; then
                        set -- "$@" "$module";
                        echo "$module";
                    fi
                ;;
            esac;
        done
    }
}

mount-all()
{
    for ARG in "$@";
    do
        mount "$ARG" ${MNTOPTS:+-o
"$MNTOPTS"}
    done
}

mount-matching()
{
    ( MNTDIR="/mnt";
   [ "$UID" != 0 ] && SUDO=sudo
   blkid | grep-e "$@" | {
        IFS=" ";
        while read -r DEV PROPERTIES; do
            DEV=${DEV%:};
            unset LABEL UUID TYPE;
            eval "$PROPERTIES";
            MNT="$MNTDIR/${LABEL:-${DEV##*/}}";
            if ! is-mounted "$DEV" && ! is-mounted "$MNT"; then
                $SUDO mkdir -p "$MNT";
                echo "Mounting $DEV to $MNT ..." 1>&2;
                $SUDO mount "$DEV" "$MNT" ${MNTOPTS:+-o
"$MNTOPTS"}
            fi;
        done
    } )
}

mount-remaining()
{
    ( MNT="${1:-/mnt}";
    [ "$UID" != 0 ] && SUDO=sudo
    for DEV in $(not-mounted-disks); do
        LABEL=` disk-label "$DEV"`
				TYPE=` blkvars "$DEV" TYPE`
				case "$TYPE" in
					swap) continue ;;
				esac
        MNTDIR="$MNT/${LABEL:-${DEV##*/}}"
        $SUDO mkdir -p "$MNTDIR";
        echo "Mounting $DEV to $MNTDIR ..." 1>&2
        $SUDO mount "$DEV" "$MNTDIR" ${MNTOPTS:+-o
"$MNTOPTS"};
    done )
}

mounted-devices() {
  (IFS=" "
	unset PREV
	while read -r DEV MNT FSTYPE OPTS A B; do
		case "$DEV" in
			rootfs | /dev/root) DEV=`get-rootfs` ;;
			/*) ;;
			*) continue	;;
		esac
		[ "$DEV" != "$PREV" ] && echo "$DEV"
		PREV="$DEV"
	done) </proc/mounts
}

mountpoint-by-label() {
 (IFS="
 	"
  for MNT in $(wmic Path win32_volume where "Label='$1'" Get DriveLetter /format:list 2>&1); do
    case "$MNT" in
      DriveLetter=*) 
        MNT=${MNT#DriveLetter=}
        MNT=${MNT:0:1}:
        break
      ;;
    esac
  done
  [ -n "$MNT" ] && { echo "$MNT" | tr "[:"{upper,lower}":]"; })
} ||

mountpoint-by-label() {
 (if [ -e /dev/disks/by-label/"$1" ]; then
    mountpoint-for-device "$1"
  else
    DEV=$(blkid -L "$1")
    if [ -n "$DEV" -a -e "$DEV" ]; then
      mountpoint-for-device "$DEV"
    fi
  fi)
}

mountpoint-for-device()
{
    ( set -- $(grep "^$1 " /proc/mounts |awkp 2);
    echo "$1" )
}

mountpoint-for-file()
{
    ( df "$1" | sed 1d | awkp 6 )
}

mountpoints()
{
    ( while :; do
        case "$1" in
            -u | --user)
                USER=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    function lsmnt()
    {
        if [ -e /proc/mounts ]; then
            awk '{ print $2'"${1:+.\"/${1#/}\"} }" /proc/mounts;
        else
            if type df 2> /dev/null > /dev/null; then
                :;
            else
                ( IFS=" ";
                mount | while read -r DRIVE ON MNT TYPE USER OPTS; do
                    if [ -n "$MNT" -a -d "$MNT" ]; then
                        echo "$MNT${1:+/${1#/}}$";
                    fi;
                done );
            fi;
        fi
    };
    CMD="lsmnt \"\$@\"";
    [ "$USER" = true ] && CMD="$CMD | grep -vE '^(/\$|/proc|/sys|/dev)'";
    eval "$CMD" )
}

msg()
{
    echo "${me:+$me: }$@" 1>&2
}

msgbegin()
{
    echo -n "${me:+$me: }$@" 1>&2
}

msgcontinue()
{
    echo -n "$@" 1>&2
}

msgend()
{
    echo "$@" 1>&2
}

msiexec()
{
    ( IFS="
";
    IFS=" $IFS";
    while :; do
        case "$1" in
            -*)
                ARGS="${ARGS+
}/${1#-}";
                shift
            ;;
            /?)
                ARGS="${ARGS+
}${1}";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    "$COMSPEC" "/C" "${MSIEXEC} $ARGS $(msyspath -w "$@")" )
}

msleep()
{
    local sec=$((${1:-0} / 1000)) msec=$((${1:-0} % 1000));
    while [ "${#msec}" -lt 3 ]; do
        msec="0$msec";
    done;
    sleep $((sec)).$msec
}

msyspath()
{
 (MODE=msys
  while :; do
    case "$1" in
      -w) MODE=win32; shift ;;
      -m) MODE=mixed; shift ;;
      *) break ;;
    esac
  done
  CMD=_msyspath
  if [ "$1" != "-" -a "$#" -gt 0 ]; then
    CMD="echo \"\$*\" |$CMD"
  fi
  eval "$CMD"
  exit $?)
}

multiline_list()
{
 (IFS="
 "
  : ${INDENT='  '}
  while :; do
    case "$1" in
      -i) INDENT=$2 && shift 2 ;;
      -i*) INDENT=${2#-i} && shift
      ;;
      *) break ;;
    esac
  done

  CMD='echo -n " \\
$INDENT$LINE"'
  [ $# -ge 1 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}

multiply-resolution()
{
    ( WIDTH=${1%%x*};
    HEIGHT=${1#*x};
    echo $((WIDTH * $2))x$((HEIGHT * $2)) )
}

myip()
{
    ( IFS=" " e_ip="[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" e_nn="[^0-9]*";
    for host in ${@:-$INET_getip_hosts};
    do
        msg "Checking $host...";
        myip=$(curl -s --socks5 127.0.0.1:9050 "$host" |
         sed -n -e "/${e_nn}127.0.0.1${e_nn}/ d"                   -e "/${e_nn}192.168\./ d"                   -e "/${e_nn}10\./ d"                   -e "/$e_ip/ {
                      s|^${e_nn}\\($e_ip\\)${e_nn}\$|\\1|
                      p
                      q
                    }");
        if ip4_valid "$myip"; then
            echo "$myip";
            exit 0;
        fi;
    done;
    exit 1 )
}

myrealpath()
{
 (for ARG; do
    DIR=` dirname "$ARG" `;
    BASE=` basename "$ARG" `;
    cd "$DIR";
    if [ -h "$BASE" ]; then
    FILE=` readlink "$BASE"`;
    fi;
    DIR=` dirname "$FILE"`;
    BASE=`basename "$FILE"`;
    if is-relative "$ARG"; then
    DIR="$PWD/$DIR";
    fi;
    DIR=$(cd "$DIR"; pwd -P);
    echo "$DIR/$BASE"
  done)
}

neighbours()
{
    while test "${2+set}" = set; do
        echo "$1" ${2+"$2"};
        shift;
    done
}

not-mounted-disks()
{
    ( IFS="
";
    for DISK in $(all-disks);
    do
        is-mounted "$DISK" || echo "$DISK";
    done )
}

notice()
{
    msg "NOTICE: $@"
}

ntfs-get-uuid()
{
    ( IFS=" ";
    set -- $(  dd if="$1" bs=1 skip=$((0x48)) count=8 |hexdump -C -n8);
    IFS="";
    echo "${*:2:8}" )
}

output-boot-entry()
{
 (
  [ -z "$FORMAT" ] && FORMAT="$1"
  case "$FORMAT" in
    grub4dos)
       echo "title "${TITLE//"
"/"\\n"}
         [ "$CMDS" ] && echo -e "CMDS${TYPE:+ ($TYPE)}:\n$CMDS"| sed 's,^,#,'
       if [ "$KERNEL" ]; then
        echo "kernel $KERNEL"
       [ "$INITRD" ] && echo "initrd $INITRD"
       fi

    ;;
    grub2)
       echo "menuentry \"$TITLE\" {"
       echo "  linux $KERNEL"
       echo "  initrd $INITRD"
       echo "}"
    ;;
    syslinux|isolinux)
       [ -z "$LABEL" ] && LABEL=$(canonicalize -m 12 -l "$TITLE")
       echo "label $LABEL"
       echo "  menu label ${TITLE%%
*}"
       if [ "$KERNEL" ]; then
         set -- $KERNEL
         echo "  kernel $1"
         shift
         [ "$INITRD" ] && set -- initrd="$INITRD" "$@"
         [ $# -gt 0 ] &&
         echo "  append" $@
       fi

       if [ "$CMDS" ]; then
         echo -e "CMDS${TYPE:+ ($TYPE)}:\n$CMDS" |sed 's,^,  #,'
         fi

     ;;
  esac
  echo
 )
}

packed-upx-files()
{
    upx -l "$@" 2>&1 | sed -n '$ { \,files\s*\]$,d } ;; $! { \,->, s,.*->\s\+[0-9]\+\s\+[.0-9]\+%\s\+[^ ]\+\s\+\(.*\),\1,p }'
}

parse-boot-entry()
{
  clear-boot-entry() {  TYPE= LABEL= TITLE= KERNEL= INITRD= CMDS=; }
   NL="
"
  unset LINEBUF

  getline()
  {
    if [ -n "$LINEBUF" ]; then
      LINE="${LINEBUF%%$NL*}"
      case "$LINE" in
        EOF\ *) T=; clear-boot-entry; return 1 ;;
        *) LINEBUF=${LINEBUF#"$LINE"}; LINEBUF=${LINEBUF#"$NL"} ;;
        esac
    else
      if ! read -r LINE; then
        LINE=""
        LINEBUF="${LINEBUF:+$LINEBUF$NL}EOF $?"
        return 0
      fi
    fi
    OLDIFS="$IFS"
    IFS=" "
    set -- $LINE
    CMD=$(echo "$1" | tr [:upper:] [:lower:])
    shift
    ARG="$*"
    IFS="$OLDIFS"
  }
  ungetline() { LINEBUF="$LINE${LINEBUF:+$NL$LINEBUF}"; }

  while :; do
    getline || return $?
    while [ "$LINE" != "${LINE#' '}" ]; do LINE=${LINE#' '}; done
    [ -z "$LINE" -a -n "$TYPE" ] && return 0
    [ -z "$CMD" ] && continue
    if [ -z "$T"  ]; then
      clear-boot-entry
	    case "$CMD" in
	      menuentry) T=grub; TITLE=${LINE#*\"}; TITLE=${TITLE%\"*\{} ;;
	      title) T=oldgrub; TITLE=${ARG}; TITLE=${TITLE//"\\n"/"$NL"} ;;
	      label) T=syslinux LABEL=${ARG} ;;
#	      menu | *MENU*LABEL*) T=syslinux; TITLE=${LINE#*MENU}; TITLE=${TITLE#*LABEL}; TITLE=${TITLE#*label}; TITLE=${TITLE/^/} ;;
	      *) continue ;;
	    esac
	    LABEL=${LABEL#' '}
	    TITLE=${TITLE#' '}
    else
    TYPE="$T"
    ARG=${ARG//"\\n"/"$NL"}
    echo "+ CMD=$CMD ARG=$ARG" 1>&2
      case "$T" in
         syslinux)
            case "$CMD" in
               '#'*) continue ;;
              kernel) KERNEL="${LINE#*kernel\ }" ;;
              append)
                 IFS="$IFS "
                 set -- ${LINE#*append\ }
                 for ARG; do
                   case "$ARG" in
                     initrd=*) INITRD="${ARG#*=}" ;;
                     *) KERNEL="${KERNEL:+$KERNEL }$ARG" ;;
                   esac
                 done
                  ;;
              menu)  ARG=${ARG/^/}; TITLE="${TITLE:+$TITLE$NL}${ARG}" ;;
              label)  ungetline; unset T; return 0 ;;
           *) [ -n "$LINE" ] && CMDS="${CMDS:+$CMDS$NL}$LINE" ;;

            esac
         ;;
         grub)
            case "$CMD" in
               '#'*) continue ;;
              linux) KERNEL="${LINE#*linux*\ }" ;;
              initrd) INITRD="${LINE#*initrd*\ }" ;;
              chainloader|  configfile) CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
              menuentry) ungetline; unset T; return 0 ;;
              *)  CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
            esac
         ;;
         oldgrub)
            case "$CMD" in
               '#'*) continue ;;
              kernel) KERNEL="${LINE#*kernel*\ }" ;;
              initrd) INITRD="${LINE#*initrd*\ }" ;;
              #map*|find*|chainloader*|root*|configfile*|set*|cat*|timeout*|default*|rootnoverify*|savedefault*|terminal*|fallback*|echo*|color*|lock*|write*|splashimage*|iftitle*|graphicsmode*|calc*|menu*|found*)  CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
              title*) ungetline; unset T; return 0 ;;
              *) [ -n "$LINE" ] && CMDS="${CMDS:+$CMDS$NL}$LINE" ;;
            esac
         ;;
       esac
      fi
  done
}

partition-table-type()
{
    ( if command-exists "parted"; then
        parted "$1" p | sed -n 's,.*Table:\s\+,,p';
    else
        ( eval "$(  gdisk -l "$(disk-device-for-partition "$1")" |sed 's,\s*not present$,,' |sed -n  's,^\s*\([[:upper:]]\+\):\(\s*\)\(.*\),\1="\3",p')";
        if [ "$MBR" -a "$GPT" ]; then
            echo "mbr+gpt";
        else
            if [ "$MBR" ]; then
                echo "mbr";
            else
                if [ "$GPT" ]; then
                    echo "gpt";
                fi;
            fi;
        fi );
    fi )
}

path-executables()
{
    ( IFS=":;";
    for DIR in $PATH;
    do
        ( cd "$DIR";
        for FILE in *;
        do
            test -f "$FILE" -a -x "$FILE" && echo "$FILE";
        done );
    done ) 2> /dev/null
}

pathmunge()
{
  while :; do
    case "$1" in
      -v) PATHVAR="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  local IFS=":";
  : ${OS=`uname -o | head -n1`};
  case "$OS:$1" in
      [Mm]sys:*[:\\]*)
          tmp="$1";
          shift;
          set -- `${PATHTOOL:-msyspath} "$tmp"` "$@"
      ;;
  esac;
  if ! eval "echo \"\${${PATHVAR-PATH}}\"" | grep -E -q "(^|:)$1($|:)"; then
      if test "$2" = "after"; then
          eval "${PATHVAR-PATH}=\"\${${PATHVAR-PATH}}:\$1\"";
      else
          eval "${PATHVAR-PATH}=\"\$1:\${${PATHVAR-PATH}}\"";
      fi;
  fi
  unset PATHVAR
}

pathremove() {
  old_IFS="$IFS"
  IFS=":"
	RET=1
  unset NEWPATH

  for DIR in $PATH; do
    for ARG; do
      case "$DIR" in
        $ARG) RET=0; continue 2 ;;
      esac
    done
    NEWPATH="${NEWPATH+$NEWPATH:}$DIR"
  done

  PATH="$NEWPATH"
  IFS="$old_IFS"
  unset NEWPATH old_IFS
	return $RET
}

pdfpextr()
{
(FIRST=$(($1)) LAST=$(($2))
    # this function uses 3 arguments:
    #     $1 is the first page of the range to extract
    #     $2 is the last page of the range to extract
    #     $3 is the input file
    #     output file will be named "inputfile_pXX-pYY.pdf"
    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage="$FIRST" \
       -dLastPage="$LAST" \
       -sOutputFile=${3%.[Pp][Dd][Ff]}_p"$FIRST"-p"$LAST".pdf \
       "${3}"
    )
}

pid-args()
{
  pid-of "$@" | sed -n  "/^[0-9]\+$/ s,^,-p\n,p"
}

pid-of() {
   (if ps --help 2>&1 |grep -q '\-W'; then
       PGREP_CMD='ps -aW |grep -i "$ARG" | awkp'
    elif type pgrep 2>/dev/null >/dev/null; then
       PGREP_CMD='pgrep -f "$ARG"'
    else
       PGREP_CMD='ps -ax | grep -i "$ARG" | awkp'
    fi
    for ARG in "$@"; do
      eval "$PGREP_CMD"
    done | sed -n 's/^\([0-9]\+\)\r\?$/\1/p')
}

pkg-name()
{
    ( for ARG in "$@";
    do
        ARG=${ARG%.t?z};
        ARG=${ARG%.[tdr][aegpx][rbmz]*};
        ARG=${ARG%.*};
        echo "${ARG%%-[0-9]*}";
    done )
}

pkginst()
{
    ( PKGS=`pkgsearch "$@"`;
    set -- ${PKGS%%" "*};
    if [ $# -gt 0 ]; then
        sudo yum -y install "$@";
    fi )
}

pkgsearch()
{
    ( EXCLUDE='-common -data -debug -doc -docs -el -examples -fonts -javadoc -static -tests -theme';
    for ARG in "$@";
    do
        sudo yum -y search "${ARG%%[!-A-Za-z0-9]*}" | grep --color=auto --color=auto --color=auto --color=auto -i "$ARG[^ ]* : ";
    done | sed -n "/^[^ ]/ s,\..* : , : ,p" | grep --color=auto --color=auto --color=auto --color=auto -vE "($(IFS='| '; set -- $EXCLUDE; echo "$*"))" | uniq )
}

player-file()
{
  ( SED_SCRIPT=
	while :; do
					case "$1" in
									-H|--no*hidden) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|/\\.|d" ; shift ;;
									-P|--no*proc) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|^/proc|d" ; shift ;;
					-x|--exclude) SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|${2//*/.*}|d" ; shift 2  ;;
					-x=*|--exclude=*) P=${1#*=}; SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }\\|^"${P//"*"/".*"}"\$|d" ; shift   ;;
					*) break ;;
					esac
	done
	SED_SCRIPT="${SED_SCRIPT:+$SED_SCRIPT ;; }s| ([^)]*)\$||"
	  lsof -n $(pid-args "${@-mplayer}") 2> /dev/null 2> /dev/null 2> /dev/null 2> /dev/null | grep  -E ' [0-9]+[^ ]* +REG ' | grep --color=auto -vE ' (mem|txt|DEL) ' | cut-lsof NAME |sed "$SED_SCRIPT" )
}

proc-by-pid() {
  if ps --help 2>&1 |grep -q '\-W'; then
    PSARGS="-W"
  fi
  for ARG; do
     ps $PSARGS -p "$ARG" | sed 1d
  done |cut-ls-l 7
}

proc-mount()
{
    for ARG in "$@";
    do
        ( grep --color=auto --color=auto --color=auto "^$ARG" /proc/mounts );
    done
}

prof()
{
    PROF="$HOME/.bash_profile";
    case "$1" in
        load* | source* | relo*)
            . "$PROF"
        ;;
        edit)
            "${2:-$EDITOR}" "$(cygpath -m "$PROF")"
        ;;
    esac
}

pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

pushv_unique()
{
    local v=$1 s IFS=${IFS%${IFS#?}};
    shift;
    for s in "$@";
    do
        if eval "! isin \$s \${$v}"; then
            pushv "$v" "$s";
        else
            return 1;
        fi;
    done
}

quiet()
{
    "$@" 2> /dev/null
}

rand()
{
    local rot=$(( ${random_seed:-0xdeadbeef} & 0x1f ));
    local xor=`expr ${random_seed:-0xdeadbeef} \* (${random_seed:-0xdeadbeef} "<<" $rot)`;
    random_seed=$(( ( $(bitrotate "${random_seed:-0xdeadbeef}" "$rot") ^ $xor) & 0xffffffff ));
    expr "$random_seed" % ${1:-4294967296}
}

randhex()
{
    for n in $(seq 1 ${1:-16});
    do
        printf "${2:-0x}%02x\n" $((RANDOM % 256 ));
    done
}

random_acquire()
{
    local n IFS="$newline";
    for n in $(echo "$@" | hexdump -d | sed "s,^[0-9a-f]\+\s*,,;s,\s\+,\n,g");
    do
        local rot=$(( (${random_seed:-0xdeadbeef} + (n >> 11)) & 0x1f)) xor=$((${random_seed:-0xdeadbeef} - (n & 0x07ff)));
        random_seed=$(( ($(bitrotate $(( ${random_seed:-0xdeadbeef} )) $rot) ^ $xor) & 0xffffffff ));
    done;
    echo "seed: ${random_seed:-0xdeadbeef}"
}

rangearg()
{
    ( S="$1";
    E="$2";
    shift 2;
    eval set -- "\${@:$S:$E}";
    echo "$*" )
}

rcat()
{
    local opts= args=;
    while test -n "$1"; do
        case $1 in
            *)
                pushv args "$1"
            ;;
            -*)
                pushv opts "$1"
            ;;
        esac;
        shift;
    done;
    grep --color=auto --color=auto --color=auto --color=no $opts '.*' $args
}

regexp_to_fnmatch()
{
    ( expr=$1;
    case $expr in
        '^'*)
            expr="${expr#^}"
        ;;
        *)
            expr="*${expr}"
        ;;
    esac;
    case $expr in
        *'$')
            expr="${expr%$}"
        ;;
        '*')

        ;;
        *)
            expr="${expr}*"
        ;;
    esac;
    case $expr in
        *'.*'*)
            expr=`echo "$expr" | sed "s,\.\*,\*,g"`
        ;;
    esac;
    case $expr in
        *'.'*)
            expr=`echo "$expr" | sed "s,\.,\?,g"`
        ;;
    esac;
    echo "$expr" )
}

reload()
{
    local script retcode var force="no";
    while :; do
        case $1 in
            -f)
                force="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    script=$(require -p -n ${1%.sh});
    name=${script%.sh}_sh;
    var=$(echo lib/$name | sed -e s,/,_,g);
    if test "$force" = yes; then
        verbose "Forcing reload of $script";
        local fn;
        for fn in $(sed -n -e 's/^\([_a-z][_0-9a-z]*\)().*/\1/p' $shlibdir/$script);
        do
            case $fn in
                require | verbose | msg)
                    continue
                ;;
            esac;
            verbose "unset -f $fn";
            unset -f $fn;
        done;
    fi;
    verbose "unset $var";
    unset "$var";
    verbose "require $script";
    source "$shlibdir/$script"
}

remove-cond-include() {
 (INC="$1"
  shift

  INCNAME="${INC##*/include/}"
  INCDEF=HAVE_$(echo "$INCNAME" | sed 's,[/.],_,g' | tr '[[:'{lower,upper}':]]') 

  sed -i "\\|^\s*#\s*if[^\n]*def[^\n]*$INCDEF| {
    :lp
    /#\s*endif/! { N; b lp; }

   s|^\s*#\s*if[^\n]*def[^\n]*$INCDEF[^\n]*\n||
   s|[^\n]*#[^\n]*endif[^\n]*$||
  }" "$@"

  )
}

removeprefix()
{
 (PREFIX=$1; shift
  CMD='echo "${LINE#$PREFIX}"'
  [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done"
  eval "$CMD"
 )
}

removesuffix()
{
 (SUFFIX=$1; shift
  CMD='echo "${LINE%$SUFFIX}"'
  if [ $# -gt 0 ]; then
    CMD="for LINE; do $CMD; done"
  else
    CMD="while read -r LINE; do $CMD; done"
  fi
  eval "$CMD")
}

remove_emptylines()
{
    sed -e '/^\s*$/d' "$@"
}

require()
{
    local mask script retcode cmd="source" pre="";
    while :; do
        case $1 in
            -p)
                cmd="echo"
            ;;
            -n)
                pre="$shlibdir/"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    script=${1%.sh};
    for mask in $shlibdir/$script.sh $shlibdir/*/${script%.sh}.sh $shlibdir/*/*/${script%.sh}.sh;
    do
        if test -r "$mask"; then
            if test "$cmd" = echo && test -n "$pre"; then
                mask=${mask#$pre};
            fi;
            $cmd "$mask";
            return 0;
        fi;
    done;
    echo "ERROR: loading shell script library $shlibdir/$script.sh" 1>&2;
    return 127
}

resolution()
{  
	(minfo "$@"|sed -n "/Width\s*: / { N; /Height\s*:/ { s,Width\s*:,, ; s,[^:\n0-9]\+: \+\([^:]*\)\$,\1,g; s|^\s*||; s|\([0-9]\)\s\+\([0-9]\)|\1\2|g; s|\s*pixels||g;  s|\n\([^:]*:\)\?|x|g; p } }")
}

retcode()
{
    "$@";
    msg "\$? = $?"
}

reverse()
{
    ( INDEX=$#;
    while [ "$INDEX" -gt 0 ]; do
        eval "echo \"\${$INDEX}\"";
        INDEX=`expr $INDEX - 1`;
    done )
}

rgb()
{
    ( c=${1#'#'};
    r=$(( 0x${c:0:2} ));
    g=$(( 0x${c:2:2} ));
    b=$(( 0x${c:4:2} ));
    [ "${c:6:2}" ] && a=$(( 0x${c:6:2} )) || a=;
    case "$2" in
        r)
            echo $((r))
        ;;
        g)
            echo $((g))
        ;;
        b)
            echo $((b))
        ;;
        a)
            echo $((a))
        ;;
        y)
            echo $(( (($r + $g + $b) + 2) / 3 ))
        ;;
        yuv)
            y=$(( ((66*${r}+129*${g}+25*${b}+128)>>8)+16 ));
            u=$(( ((-38*${r}-74*${g}+112*${b}+128)>>8)+128 ));
            v=$(( ((112*${r}-94*${g}-18*${b}+128)>>8)+128 ));
            echo $y $u $v
        ;;
        hsl)
            min=$(min $r $g $b);
            max=$(max $r $g $b);
            if [ ! "$min" -eq "$max" ]; then
                if [ "$r" -eq "$max" -a "$g" -ge "$b" ]; then
                    h=$(( (g-b)*85/(max-min)/2 ));
                else
                    if [ "$r" -eq "$max" -a "$g" -lt "$b" ]; then
                        h=$(( (g-b)*85/(max-min)/2+255 ));
                    else
                        if [ "$g" -eq "$max" ]; then
                            h=$(( (b-r)*85/(max-min)/2+85 ));
                        fi;
                    fi;
                fi;
            fi;
            l=$(( (min+max) / 2 ));
            if [ "$min" -eq "$max" ]; then
                s=0;
            else
                if [ "$((min+max))" -lt 256 ]; then
                    s=$(( (max-min)*256/(min+max) ));
                else
                    s=$(( (max-min)*256/(512-min-max) ));
                fi;
            fi;
            echo $h $s $l
        ;;
        *)
            echo $(($r)) $(($g)) $(($b)) ${a:+$(($a))}
        ;;
    esac )
}

rmv()
{
    "${COMMAND-command}" rsync -r --remove-source-files -v --partial --size-only --inplace -D --links "$@"
}

rm_arch()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    sed 's,\.[^\.]*$,,' )
}

rm_ver()
{
    ( IFS="
";
    [ $# -gt 0 ] && exec <<< "$*";
    sed 's,-[^-]*$,,' )
}

rpm-cmd() {
  OPTS= OUTPUT=
  while :; do
    case "$1" in
      -o) OUTPUT="$2"; shift 2 ;; -o*) OUTPUT="${1#-o}"; shift  ;; --output=*) OUTPUT="${1#*=}"; shift  ;;
      -*) OPTS="${OPTS:+$OPTS$IFS}$1"; shift ;;
      --) shift; break ;;
      *) break ;;
    esac
  done

 #CMD="addprefix \"\$ARG: \""
 CMD="sed \"s|^\\./|| ;; s|^|\$ARG: |\""
 #N=$#

  while [ $# -gt 0 ]; do
    ARG="$1"
    shift
   (case "$ARG" in
      #*://*) DLCMD="wget -q -O - \"\$ARG\" | rpm2cpio /dev/stdin" ;;
      #*://*) DLCMD="lynx -source \"\$ARG\" | rpm2cpio /dev/stdin" ;;
      #*://*) DLCMD="lynx -source \"\$ARG\" | rpm2cpio /dev/stdin" ;;
    *://*) 
      MIRRORLIST=`curl -s "$ARG.mirrorlist" |sed -n 's,\s*<li><a href="\([^"]*\.rpm\)">.*,\1,p'`

      if [ -n "$MIRRORLIST" ]; then
        set -- $MIRRORLIST 
      else
        set -- "$ARG"
      fi
      DLCMD='wget -q -O - "$1" | rpm2cpio /dev/stdin'
      ;;
      *) set -- "$ARG"
        DLCMD='rpm2cpio "$ARG"'
        ;;
    esac
    CMD="$DLCMD | (${OUTPUT:+cd \"\$OUTPUT\"; }cpio \${OPTS:--t} 2>/dev/null)${CMD:+ | $CMD}"
    while [ $# -gt 0 ]; do 
      eval "( $CMD ) 2>/dev/null" && exit 0
      #echo continue 1>&2
      shift
    done
    
    echo "Failed to list $ARG" 1>&2
    exit 1)
  done
}

rpm-list() {
  rpm-cmd -t -- "$@"
}

rpm-extract() {
  rpm-cmd -i -d -u -- "$@"
}

scriptdir()
{
    local absdir reldir thisdir="`pwd`";
    if [ "$0" != "${0%/*}" ]; then
        reldir="${0%/*}";
    fi;
    if [ "${reldir#/}" != "$reldir" ]; then
        absdir=`cd $reldir && pwd`;
    else
        absdir=`cd $thisdir/$reldir && pwd`;
    fi;
    echo $absdir
}

set_ps1()
{
    local b="\\[\\e[37;1m\\]" d="\\[\\e[0;38m\\]" g="\\[\\e[1;36m\\]" n="\\[\\e[0m\\]";
    export PS1="$n\\u$g@$n\\h$g<$n\\w$g>$n \\\$ "
}

shell-functions()
{
    ( . require.sh;
    require script;
    declare -f | script_fnlist )
}

some()
{
    eval "while shift
  do
  case \"\`str_tolower \"\$1\"\`\" in
    $(str_tolower "$1") ) return 0 ;;
  esac
  done
  return 1"
}

sf-get-cvs-modules() {
 (CVSCMD="cvs -z3 -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG co"
#  CVSPASS="cvs -d:pserver:anonymous@\$ARG.cvs.sourceforge.net:/cvsroot/\$ARG login"
CVSPASS='echo "grep -q @$ARG.cvs.sourceforge.net ~/.cvspass 2>/dev/null || cat <<\\EOF >>~/.cvspass
\1 :pserver:anonymous@$ARG.cvs.sourceforge.net:2401/cvsroot/$ARG A
EOF"'
  for ARG; do
    CMD="curl -s http://$ARG.cvs.sourceforge.net/viewvc/$ARG/ | sed -n \"s|^\\([^<>/]\+\\)/</a>\$|\\1|p\""
	 (set -- $(eval "$CMD")
		test $# -gt 1 && DSTDIR="${ARG}-cvs/\${MODULE}" || DSTDIR="${ARG}-cvs"
		CMD="${CVSCMD} -d ${DSTDIR} -P \${MODULE}"
		#[ -n "$DSTDIR" ] && CMD="(cd ${DSTDIR%/} && $CMD)"
		CMD="echo \"$CMD\""
		
		CMD="for MODULE; do $CMD; done"
		[ -n "$DSTDIR" ] && CMD="echo \"mkdir -p ${DSTDIR%/}\"; $CMD"
		[ -n "$CVSPASS" ] && CMD="$CVSPASS; $CMD"
		[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
		eval "$CMD")
  done)
}

sf-get-svn-modules() { 
  require xml
 (for ARG; do
    curl -s http://sourceforge.net/p/"$ARG"/{svn,code}/HEAD/tree/ | 
      xml_get a data-url |
      head -n1
  done |
    sed "s|-svn\$|| ;; s|-code\$||" |
    addsuffix "-svn")
}

sf-get-git-repos() {
  require xml
 (for ARG; do
    curl -s  "http://sourceforge.net/p/$ARG/code-git/ci/master/tree/" |
			xml_get a data-url |
			head -n1
  done |
    sed "s|-git\$|| ;; s|-code\$||" |
    addsuffix "-git")
}

split()
{
    local _a__ _s__="$1";
    for _a__ in $_s__;
    do
        shift;
        eval "$1='`echo "$_a__" | sed "s,','\\\\'',g"`'";
    done
}

srate()
{
  ( N=$#
  for ARG in "$@";
  do
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*\\([A-Za-z]*\\)Hz.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1\\2,p"

    SRATE=$(file "$ARG" |sed -n "$EXPR" |sed 's,[Kk]$,000,')
    #echo "EXPR='$EXPR'" 1>&2

    test -n "$SRATE" && echo "$SRATE" || (
      #mminfo "$ARG" | sed -n "/Sampling rate[^=]*=/ { s,Hz,,; s,[Kk],000, ; s,\.[0-9]*\$,, ; s|^|$ARG:|; p }" | tail -n1
      SRATE=$(mminfo "$ARG" | sed -n "/Sampling rate[^=]*=/ { s,.*[:=],,; s,Hz,,; s,\.[0-9]*\$,, ; s|^|$ARG:|;  p }" | tail -n1)
      SRATE=${SRATE##*:}
      case "$SRATE" in
          *[Kk])
             CMD='SRATE=$(echo "'${SRATE%[Kk]}' * 1000" | bc -l); SRATE=${SRATE%.*}'
             #echo "$CMD" 1>&2
             eval "$CMD"
          ;;
       esac
      [ "$N" -gt 1 ]  && SRATE="$ARG:$SRATE"
      echo "$SRATE"


      )
  done )
}

submatch()
{
    local arg exp src dst result=$1 && shift;
    for arg in "$@";
    do
        exp="${arg#*=}";
        dst="${arg%$exp}";
        dst="${dst%=}";
        src="${exp%%[!A-Za-z_]*}";
        exp="${exp#$src}";
        eval ${dst:=$result}='${'${src:=$result}$exp'}';
    done
}

subst_script()
{
    local var script value IFS="$obj_s";
    for var in "$@";
    do
        if [ "$var" != "${var%%=*}" ]; then
            value=${var#*=};
            value=`echo "$value" | sed 's,\\\\,\\\\\\\\,g'`;
            array_push script "s°@${var%%=*}@°`array_implode value '\n'`°g";
        else
            value=`var_get "$var"`;
            value=`echo "$value" | sed 's,\\\\,\\\\\\\\,g'`;
            array_push script "s°@$var@°`array_implode value '\n'`°g";
        fi;
    done;
    array_implode script ';'
}

symlink-lib()
{
    ( while :; do
        case "$1" in
            -p)
                PRINT_ONLY=echo;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    for ARG in "$@";
    do
        ( IFS=".";
        set -- $ARG;
        unset NAME;
        while [ "$1" != so ]; do
            NAME="${NAME+$NAME${IFS:0:1}}$1";
            shift;
        done;
        I=$(( $# - 1 ));
        N=$#;
        unset PREV;
        while [ "$I" -ge 1 ]; do
            EXT=$(rangearg 1  "$I" "$@");
            LINK="$NAME${EXT:+.$EXT}";
            TARGET="$ARG";
            [ -n "$PREV" ] && TARGET="$PREV";
            ${PRINT_ONLY} ln -svf "$TARGET" "$LINK";
            I=$((I - 1));
            PREV="$LINK";
        done );
    done )
}

tcp-check() {
        (TIMEOUT=10
        for ARG; do
        HOST=${ARG%:*}
        PORT=${ARG#$HOST:}
        
        if type tcping 2>/dev/null >/dev/null; then
          CMD='tcping -q -t "$TIMEOUT" "$HOST" "$PORT"; echo "$?"'
        else
          CMD='echo -n |(nc -w 10 "$HOST" "$PORT" 2>/dev/null >/dev/null;  echo "$?")'
        fi

        RET=`eval "$CMD"`
        
        if [ "$RET" -eq 0 ]; then
          echo "$HOST:$PORT"
        fi

        if [ $# -le 1 ]; then
          exit "$RET"
        fi
      done)
}

tempnam()
{
    local IFS=" $newline";
    local pfx=${0##*/};
    local prefix=${2-${tmppfx-${pfx%:*}}};
    local path=${1-${tmpdir-"/tmp"}};
    local name=`command mktemp -u ${path:-"-t" }"${path:+/}${prefix#-}.XXXXXX"`;
    rm -rf "$name";
    echo "$name"
}

terminfo_file()
{
    ( for ARG in "$@";
    do
        F="/usr/share/terminfo/`firstletter "$ARG"`/$ARG";
        test -e "$F" && echo "$F" || {
            echo "$F not found" 1>&2;
            exit 1
        };
    done )
}

tgz2txz()
{
    ( for ARG in "$@";
    do
        zcat "$ARG" | ( xz -9 -v -f -c > "${ARG%.tgz}.txz" && rm -vf "$ARG" );
    done )
}

title()
{
				(
id3get "$1" 'TIT[0-9]'
				)

}

to-expr() { echo "${*//[!-a-zA-Z0-9_=%:\/ <>\']/.}"; }

to-sed-expr()
{
 ([ $# -gt 0 ] && exec <<<"$*"
  sed 's|[.*\\]|\\&|g ;; s|\[|\\[|g ;; s|\]|\\]|g')
}

umount-all()
{
    for ARG in "$@";
    do
        umount "$ARG";
    done
}

umount-matching()
{
    ( grep-e "$@" < /proc/mounts | {
        IFS=" ";
        while read -r DEV MNT TYPE OPTS N M; do
            echo "Unmounting $DEV, mounted at $MNT ..." 1>&2;
            umount "$MNT" || umount "$MNT";
        done
    } )
}

undotslash()
{
    sed -e "s:^\.\/::" "$@"
}

unescape_newlines()
{
    sed -e ':start
  /\$/ {
  N
  s|\\\n[ \t]*||
  b start
  }' "$@"
}

unix2date()
{
    date --date "@$1" "+%Y/%m/%d %H:%M:%S"
}

unmount-all()
{
    for ARG in "$@";
    do
        umount "$ARG";
    done
}

unpack-deb()
{
    ( for ARG in "$@";
    do
        ( TEMP=` mktemp -d `;
        trap 'rm -rf "$TEMP"' EXIT;
        ARG=` realpath "$ARG"`;
        DIR=${DESTDIR-"$PWD"};
        DEST="$DIR"/$(basename "$ARG" .deb);
        cd "$TEMP";
        ar x "$ARG";
        mkdir -p "$DEST";
        tar -C "$DEST" -xf data.tar.gz;
        [ "$?" = 0 ] && echo "Unpacked to $DEST" 1>&2 );
    done )
}

unpack()
{
    case $(mime "$1") in
        application/x-tar)
            tar ${2+-C "$2"} -xf "$1" && return 0
        ;;
        application/x-zip)
            unzip -L -qq -o ${2+-d "$2"} "$1" && return 0
        ;;
    esac;
    return 1
}

unpackable()
{
    case $(mime $1) in
        'application/x-tar')
            return 0
        ;;
        'application/x-zip')
            return 0
        ;;
    esac;
    return 1
}

usleep()
{
    local sec=$((${1:-0} / 1000000)) usec=$((${1:-0} % 1000000));
    while [ "${#usec}" -lt 6 ]; do
        usec="0$usec";
    done;
    sleep $((sec)).$usec
}

uuid_hexnums()
{
    getuuid "$1" | sed "s,[0-9A-Fa-f][0-9A-Fa-f], ${2:-0x}&,g" | sed "s,^\s*,, ; s,\s\+,\n,g"
}

verbose()
{
    local msg="$*" a=`eval "echo \"\${$#}\""` IFS="
";
    if [ "$#" = 1 ]; then
        a=1;
    fi;
    if ! [ "$a" -ge 0 ]; then
        a=0;
    fi 2> /dev/null > /dev/null;
    if [ "$verbosity" -ge "$a" ]; then
        msg "${msg%?$a}";
    fi
}

video-height()
{
    ( for ARG in "$@";
    do
        [ $# -gt 1 ] && PFX="$ARG: " || unset PFX;
        mminfo "$ARG" | sed -n "s|^Height=|$PFX|p";
    done )
}

video-width()
{
    ( for ARG in "$@";
    do
        [ $# -gt 1 ] && PFX="$ARG: " || unset PFX;
        mminfo "$ARG" | sed -n "s|^Width=|$PFX|p";
    done )
}

vlcfile()
{
    ( IFS="
";
    set -- ` handle -p $(vlcpid)|grep -vi "$(cygpath -m "$WINDIR"| sed 's,/,.,g')"  |sed -n -u 's,.*: File  (RW-)\s\+,,p'
`;
    for X in "$@";
    do
        X=`cygpath "$X"`;
        test -f "$X" && echo "$X";
    done )
}

vlcpid()
{
    ( ps -aW | grep --color=auto --color=auto --color=auto --color=auto --color=auto --line-buffered --color=auto --line-buffered -i vlc.exe | awkp )
}

volname() { 
 ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
  for ARG in "$@"; do
      drive="$ARG"
      case "$drive" in
        ?) drive="$drive:/" ;;
        ?:) drive="$drive/" ;;
        *) drive=$(cygpath -m "$drive") ;;
      esac  
      drive=$(cygpath -m "$drive")
      NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
      eval "$ECHO"
  done)
}
#volname () { 
#   ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
#    for ARG; do
#	  drive=$(cygpath -m "$ARG")
#	  NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
#	  eval "$ECHO"
#	done)
#}

w2c()
{
    ch_conv UTF-16 UTF-8 "$@"
}

waitproc()
{
    function getprocs()
    {
        for ARG in "$@";
        do
            pgrep -f "$ARG";
        done
    };
    while [ -n "$(getprocs "$@")" ]; do
        sleep 0.5;
    done
}

warn()
{
    msg "WARNING: $@"
}

x-fn()
{ 
 (MATCH=p
  NOMATCH=D
  while :; do
    case "$1" in
      -1 | --oneline) XTRA="$XTRA; s,\s\+, ,g" ;;
      -d | --delete) MATCH=d; NOMATCH='P;D;' ;;
      *) break ;;
    esac
    shift
  done
  
  FN="$1";
  shift;
  #: ${XTRA="$XTRA; s/^/-->/; s/\n/\n-->/g"}
  sed " :lp0 
   \$ { /\n/! $NOMATCH; } 
    N
    /\n/! b lp0

    /$FN[^\n]*\$/ {

      /)/ b endargs
      :lp1
      N
      /)/! b lp1
      
      :endargs

      /).*;\s*$/ b endfn

      :lp2
      N
      /\n}[ \t]*$/! b lp2
      :endfn
      $XTRA
      $MATCH

      :endlp
      d
      n
      b endlp
      q
    }
    $NOMATCH
    b lp0

  " "$@")
}

yaourt-pkgnames() {
 (NAME='\([^ \t/]\+\)'
 sed -n "s|^${NAME}/${NAME}\s\+\(.*\)|\2|p")
}

yaourt-joinlines() {
 (while :; do 
   case "$1" in
		-n | --num*) CUT_NUM=true ;;
		-s | --state) CUT_STATE=true ;;
		*) break ;;
		esac 
		shift
	done
		while read -r LINE; do
    case "$LINE" in
			"   "*) PKG="${PKG:+$PKG - }${LINE#    }" ;;
      *) 
				[ -n "$PKG" ] && echo "$PKG"
				PKG="${LINE}"
				${CUT_STATE:-false} && 
				PKG="${PKG% \[*\]}"
				${CUT_NUM:-false} && PKG="${PKG% (*)}"
				;;
		esac
	done
	[ -n "$PKG" ] && echo "$PKG")
}

yaourt-cutver() {
 (NAME='\([^ \t/]\+\)'
 sed "s|^${NAME}/${NAME}\s\+\([^ \t]\+\)\s\+\(.*\)|\1/\2 \4|")
}

yaourt-cutnum() {
 #(NAME='\([^ \t/]\+\)';  sed "s|^${NAME}/${NAME}\s\+\(.*\)\s\+\(([0-9]\+)\)\(.*\)|\1/\2 \3 \5|")
 sed "s|\s\+\(([0-9]\+)\)\(.*\)| \2|"
}

yes()
{
    while :; do
        echo "${1-y}";
    done
}

_cygpath()
{
    ( FMT="cygwin";
    IFS="
";
    while :; do
        case "$1" in
            -w)
                FMT="windows";
                shift
            ;;
            -m)
                FMT="mixed";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    unset CMD PRNT EXPR;
    case "$FMT" in
        mixed | windows)
            vappend EXPR 's,^/cygdrive/\(.\)\(.*\),\1:\2,'
        ;;
        cygwin)
            vappend EXPR 's,^\(.\):\(.*\),/cygdrive/\1\2,'
        ;;
    esac;
    case "$FMT" in
        mixed | cygwin)
            vappend EXPR 's,\\,/,g'
        ;;
        windows)
            vappend EXPR 's,/,\\,g'
        ;;
    esac;
    FLTR="sed -e \"\${EXPR}\"";
    if [ $# -le 0 ]; then
        PRNT="";
    else
        PRNT="echo \"\$*\"";
    fi;
    CMD="$PRNT";
    [ "$FLTR" ] && CMD="${CMD:+$CMD|}$FLTR";
    echo "! $CMD" 1>&2;
    eval "$CMD" )
}

_msyspath()
{
 (add_to_script() { while [ "$1" ]; do SCRIPT="${SCRIPT:+$SCRIPT ;; }$1"; shift; done; }

  case $MODE in
    win*|mix*) #add_to_script "s|^${SYSDRIVE}[\\\\/]\(.\)[\\\\/]|\1:/|" "s|^${SYSDRIVE}[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
      add_to_script "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\\([\\\\/]\\)\\([^\\\\/]\\)\\?|\\1:\\2\\3|" "s|^${SYSDRIVE}[\\\\/]\\([^\\\\/]\\)\$|\\1:/|" ;;
    *) add_to_script "s|^\([A-Za-z0-9]\):|${SYSDRIVE}/\\1|" ;;
  esac
  case $MODE in
    win*|mix*)
      for MOUNT in $(mount | sed -n 's|\\|\\\\|g ;; s,\(.\):\\\(.\+\) on \(.*\) type .*,\1:\\\2|\3,p'); do
        DEV=${MOUNT%'|'*}
        MNT=${MOUNT##*'|'}
        test "$MNT" = / && DEV="$DEV\\\\"

        add_to_script "/^.:/! s|^${MNT}|${DEV}|"
       done

       #ROOT=$(mount | sed -n 's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      #add_to_script "/^.:/!  s|^|$ROOT|"
    ;;
  esac
  case "$MODE" in
    win32) add_to_script "s|/|\\\\|g" ;;
    *) add_to_script "s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) add_to_script "s|^${SYSDRIVE}/A/|${SYSDRIVE}/a/|" "s|^${SYSDRIVE}/B/|${SYSDRIVE}/b/|" "s|^${SYSDRIVE}/C/|${SYSDRIVE}/c/|" "s|^${SYSDRIVE}/D/|${SYSDRIVE}/d/|" "s|^${SYSDRIVE}/E/|${SYSDRIVE}/e/|" "s|^${SYSDRIVE}/F/|${SYSDRIVE}/f/|" "s|^${SYSDRIVE}/G/|${SYSDRIVE}/g/|" "s|^${SYSDRIVE}/H/|${SYSDRIVE}/h/|" "s|^${SYSDRIVE}/I/|${SYSDRIVE}/i/|" "s|^${SYSDRIVE}/J/|${SYSDRIVE}/j/|" "s|^${SYSDRIVE}/K/|${SYSDRIVE}/k/|" "s|^${SYSDRIVE}/L/|${SYSDRIVE}/l/|" "s|^${SYSDRIVE}/M/|${SYSDRIVE}/m/|" "s|^${SYSDRIVE}/N/|${SYSDRIVE}/n/|" "s|^${SYSDRIVE}/O/|${SYSDRIVE}/o/|" "s|^${SYSDRIVE}/P/|${SYSDRIVE}/p/|" "s|^${SYSDRIVE}/Q/|${SYSDRIVE}/q/|" "s|^${SYSDRIVE}/R/|${SYSDRIVE}/r/|" "s|^${SYSDRIVE}/S/|${SYSDRIVE}/s/|" "s|^${SYSDRIVE}/T/|${SYSDRIVE}/t/|" "s|^${SYSDRIVE}/U/|${SYSDRIVE}/u/|" "s|^${SYSDRIVE}/V/|${SYSDRIVE}/v/|" "s|^${SYSDRIVE}/W/|${SYSDRIVE}/w/|" "s|^${SYSDRIVE}/X/|${SYSDRIVE}/x/|" "s|^${SYSDRIVE}/Y/|${SYSDRIVE}/y/|" "s|^${SYSDRIVE}/Z/|${SYSDRIVE}/z/|"
    ;;
    win*)  add_to_script "s|^a:|A:|" "s|^b:|B:|" "s|^c:|C:|" "s|^d:|D:|" "s|^e:|E:|" "s|^f:|F:|" "s|^g:|G:|" "s|^h:|H:|" "s|^i:|I:|" "s|^j:|J:|" "s|^k:|K:|" "s|^l:|L:|" "s|^m:|M:|" "s|^n:|N:|" "s|^o:|O:|" "s|^p:|P:|" "s|^q:|Q:|" "s|^r:|R:|" "s|^s:|S:|" "s|^t:|T:|" "s|^u:|U:|" "s|^v:|V:|" "s|^w:|W:|" "s|^x:|X:|" "s|^y:|Y:|" "s|^z:|Z:|" ;;
  esac
  #echo "SCRIPT=$SCRIPT" 1>&2
 (sed "$SCRIPT" "$@")
 )
}
