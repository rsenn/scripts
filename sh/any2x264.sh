#!/bin/bash

. require.sh

require info
require util

vbr() {
  (VBR=$(mediainfo "$1" |sed '/^Video/ { :lp; N; /:[^\n]*$/ { b lp; }; s|.*\nBit.rate\s*:\s*\([^\n]*\)\n.*|\1| ; s, ,,; s,Kb/s,Kbps,i; s,bps$,, ; p }' -n)
  case "$VBR" in
    *[Kk]) VBR=$(echo "${VBR%[Kk]*} * 1000" | bc -l) ;;  *[Mm]) VBR=$(echo "${VBR%[Kk]*} * 10000000" | bc -l) ;;
  esac; echo "${VBR%%.*}")
}

abr() {
  (ABR=$(mediainfo "$1" | sed '/^Audio/ {  :lp; N; /:[^\n]*$/ { b lp; }; s|.*\nBit.rate\s*:\s*\([^\n]*\)\n.*|\1| ; s, ,,; s,Kb/s,Kbps,i; s,bps$,, ; p }' -n)
  case "$ABR" in
    *[Kk]) ABR=$(echo "${ABR%[Kk]*} * 1000" | bc -l) ;; *[Mm]) ABR=$(echo "${ABR%[Kk]*} * 10000000" | bc -l) ;;
  esac; echo "${ABR%%.*}")
}

resolution() {
 (mediainfo "$1" |sed '/^Video/ { :lp; N; /:[^\n]*$/ { b lp; }; s|.*\nWidth\s*:\s*\([^\n]*\)\n|\1| ; s|Height\s*:\s*\([^\n]*\)\n.*|\1| ; s, ,,;  s,pixels,x, ; s, pixels,,g; p }' -n)
}

parse_num() {
 (N=$1
  case "$N" in
    *G) N=$(( ${N%G} * 1048576 * 1024 )) ;; 
    *M) N=$(( ${N%M} * 1048576 )) ;; 
    *[Kk]) N=$(( ${N%[Kk]} * 1024 )) ;;
  esac
  echo "$N")
}

format_num() {
 (N="$1"; if [ "$N" -ge 1024 ]; then N=$(bci "$N / 1024")k
  fi; echo "$N")
}
    

var_dump() {
  (SQ="'" BS="\\"; CMD='echo'; for N; do
    CMD="${CMD:+$CMD }\"$N='\${$N//\$SQ/\$BS\$SQ}'\""
   done; eval "$CMD")
}

quote() {  (unset O
  for A; do case "$A" in
      *\ *) O="${O+$O }'$A'" ;; *)  O="${O+$O }$A" ;;
    esac; done; echo "$O")
  }

minfo() {
    mediainfo "$@" 2>&1 |${SED-sed}  -u 's,\s*:,:, ; s, pixels$,, ; s,: *\([0-9]\+\) \([0-9]\+\),: \1\2,g' 
}

bce() {
    (IFS=" "; echo "$*" | (bc  -l || echo "ERROR: Expression '$*'" 1>&2)) | ${SED-sed}  -u '/\./ s,\.\?0*$,,'
}

bci() { (IFS=" "; [ "$DEBUG" = true ] && echo "EXPR: bci '$*'" 1>&2; bce "($*) + 0.5") | ${SED-sed}   -u 's,\.[0-9]\+$,,'
}

duration()
{
echo "duration $(quote "$@")" 1>&2
    (for ARG; do minfo "$ARG" | info_get Duration| head  -n1 ; done | ${SED-sed} 's,\([0-9]\+\)\s*h,(\1 * 3600\)+, ; s,\([0-9]\+\)\s*mi\?n,(\1 * 60)+, ; s,\([0-9]\+\)\s*s,\1+, ; s,+$,,' |  
    bc  -l)
}

# calc_vbr_filesize <SIZE> <DURATION> <ABR>
calc_vbr_filesize() {
   S=$(parse_num "$1")
   D="$2"
   CPS=$(( $S / $D ))
   BPS=$(($CPS * 8))
   
   if [ -n "$3" -a "${3:-0}" -gt 0 ]; then
      AB=$(parse_num "$3")
   else 
      KBPS=$(( $BPS / 1024 ))
      AB=$(( (($KBPS / 6) + 15 ) / 16 ))
      AB=$(( $AB * 16 * 1024 ))
   fi
   
   echo "S=$S D=$D BPS=$BPS AB=$AB V=$V" 1>&2
   V=$(($BPS - $AB))
   VBR=$V
   ABR=$AB
   echo "VBR=$VBR ABR=$ABBR" 1>&2
}


is16to9()
{
    (R=`bci "( $1 / $2 ) * 3" `
    [ "$R"  -gt  4 ])
}

size2ratio()
{
    (W=${1%%x*}
    H=${1#*x}

    R=`bci "($W / $H) * 100"`
    case "$R" in
  17?) echo 177 ;;
     *) echo "$R" ;;
 esac
    )
}


any2x264() {
  unset DIR FILESIZE

  while :; do
      case "$1" in
      -abr=*|--abr=*) ABR=$(parse_num "${1#*=}"); shift ;;  -abr|--abr) ABR=$(parse_num "$2"); shift 2 ;;
      -ar=*|--ar=*) AR=$(parse_num "${1#*=}"); shift ;;  -ar|--ar) AR=$(parse_num "$2"); shift 2 ;;
      -p) PRESET="$2"; shift 2 ;;
      -b) VBR=$(parse_num "$2"); shift 2 ;;
      -a:b) ABR=$(parse_num "$2"); shift 2 ;;
      -d) DIR="$2"; shift 2 ;;
      -r) REMOVE=true; shift ;;
      -R|--resolution) RESOLUTION="$2"; shift 2 ;;
#      -s|-size|--size) SIZE="$2"; shift 2 ;; -s=*|-size=*|--size=*) SIZE=${1#*=}; shift ;;
      -S|--filesize) FILESIZE=$(parse_num "$2"); shift 2 ;; -S=*|--filesize=*) FILESIZE=$(parse_num ${1#*=}); shift ;; 
      -x) DEBUG=true; shift ;;
      -P) PRINTCMD=true; shift ;;
      -a) A="$2"; shift 2 ;;
      -c) A="${A:+-vf crop=$2}" shift 2 ;;
       *) break ;;

      esac
  done

#  case $FILESIZE in
#      *[Mm]) FILESIZE=$(( ${FILESIZE%[Mm]} * 1048576)) ;;
#      *[Kk]) FILESIZE=$(( ${FILESIZE%[Kk]} * 1024)) ;;
#  esac
#
  type avconv 2>/dev/null >/dev/null && FFMPEG=avconv
  : ${FFMPEG=ffmpeg}

  IFS="
   "
   
   
  case "$VBR" in
    *[Kk]) VBR=$((${VBR%[Kk]} * 1024)) ;;
  esac

  var_dump VBR
  #ASPECT="4:3"
  #SIZE="320x240"
#  : ${VBR:=$((800 * 1024))}

#  : ${ABR:=128000}
  : ${AR:=44100}


  unset RESOLUTIONS
  #pushv RESOLUTIONS 1920x1080
  #pushv RESOLUTIONS 1440x1080
  #pushv RESOLUTIONS 1280x720
  pushv RESOLUTIONS 1280x720
  pushv RESOLUTIONS 1024x576
  #pushv RESOLUTIONS 1000x564
  pushv RESOLUTIONS 640x368
  pushv RESOLUTIONS 480x352
  pushv RESOLUTIONS 320x240
  pushv RESOLUTIONS 960x720
  pushv RESOLUTIONS 960x540
  pushv RESOLUTIONS 950x536
  pushv RESOLUTIONS 854x480
  pushv RESOLUTIONS 852x480
  pushv RESOLUTIONS 850x480
  pushv RESOLUTIONS 768x432
  pushv RESOLUTIONS 750x420
  pushv RESOLUTIONS 720x528
  pushv RESOLUTIONS 720x480
  pushv RESOLUTIONS 720x404
  pushv RESOLUTIONS 720x400
  pushv RESOLUTIONS 720x540
  pushv RESOLUTIONS 704x394
  pushv RESOLUTIONS 640x480
  pushv RESOLUTIONS 640x360
  pushv RESOLUTIONS 608x336
  pushv RESOLUTIONS 576x320
  pushv RESOLUTIONS 480x360

  #pushv RESOLUTIONS 720x576
  #pushv RESOLUTIONS 720x480
  ##pushv RESOLUTIONS 720x405
  #pushv RESOLUTIONS 640x480
  #pushv RESOLUTIONS 640x360
  #pushv RESOLUTIONS 512x288
  #pushv RESOLUTIONS 352x288

echo "ABR=$ABR" 1>&2

  for ARG; do
   ( 
   
   DURATION=$(duration "$ARG")
   
   echo "duration='$DURATION'" 1>&2
     : ${VBR:=$(vbr "$ARG")}
     : ${ABR:=$(abr "$ARG")}
     
     : ${RESOLUTION:=$(resolution "$ARG")}


    if [ -n "$FILESIZE" ]; then 
    calc_vbr_filesize "$FILESIZE" "$DURATION" $ABR
  fi
  
    echo  VBR=$(format_num $VBR) ABR=$(format_num $ABR) RESOLUTION="$RESOLUTION" 1>&2


      OUTPUT="${ARG%.*}.mp4"
      if [ "$DIR" ]; then
      OUTPUT="$DIR"/`basename "$OUTPUT"`
     fi

   [ "$RESOLUTION" ] && SIZE="$RESOLUTION"

      if [ -z "$SIZE" ]; then
        WIDTH=`minfo "$ARG" |info_get Width`
        HEIGHT=`minfo "$ARG" |info_get Height`
        R=`size2ratio "${WIDTH}x${HEIGHT}"`
        unset SIZE

        #is16to9 $WIDTH $HEIGHT && ASPECT="16:9" #|| ASPECT="4:3"

        while read RES; do
      R2=`size2ratio "$RES"`
      echo "Check ratio $(bce "$R2 / 100")" 1>&2
            
      if [ "$R" -eq "$R2" ]; then
          SIZE="$RES"
          break
      fi
        done <<<"$RESOLUTIONS"

        if [ "$SIZE" ]; then
       echo "Size is $SIZE" 1>&2
         else
       echo "WARNING: No appropriate size (ratio `bce "$R / 100"`) found!" 1>&2
       fi
       
     fi

       if [ "$FILESIZE" ]; then

     VBR=$(bci "$FILESIZE / $(duration "$ARG") * 8  - $ABR  - 3000")

     echo "Calculated video bit rate to $VBR" 1>&2

       fi

           unset BITRATE_ARG

           if [ "$VBR" ]; then
                      if  ${FFMPEG-ffmpeg}  -help 2>&1 |grep  -q '\-b:v'; then
                                  BITRATE_ARG="-b:v $(format_num $VBR) -b:a $(format_num $ABR)"
                       else
                                  BITRATE_ARG="-b $(format_num $((VBR + ABR)))"
                      fi
              fi


  RATE=29.97
  #METAOPTS="-map_metadata   -1"
     { IFS="$IFS "; #[ "$DEBUG" = true ] && 
      set  -x; set -- \
      "$FFMPEG" 2>&1  $FFMPEGOPTS $METAOPTS \
        -strict -2 \
        -y \
        -i "$ARG" \
        $A \
        ${RATE:+-r $RATE}  \
        -f mp4 \
        -vcodec libx264 \
        ${PRESET:+-preset "$PRESET"} \
        $EXTRA_ARGS \
        ${ASPECT+-aspect "$ASPECT"} \
        ${SIZE+-s "$SIZE"}  \
        $BITRATE_ARG \
        -acodec libvo_aacenc \
        -ab $(format_num "$ABR") \
        -ar "$AR" \
        -ac 2  "${OUTPUT%.*}.out.mp4"; [ "$PRINTCMD" =  true -o "$DEBUG" = true ] && quote + "$@" 1>&2 ; [ "$PRINTCMD" = true ] || {  "$@" || exit $?; }; } && 
          { mv -vf "${OUTPUT%.???}.out.mp4" "${OUTPUT%.???}.mp4"; [ "$REMOVE" = true ] && 
            rm  -vf "$ARG" \
        ; } #|| exit $?
          
     unset SIZE
     exit 0
  ) || return $?; done
}

any2x264 "$@"
