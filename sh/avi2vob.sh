#!/bin/sh
NL="
"

# ***************************************************************
# This is a batch processing script for normalizing and converting
# a mixed collection of .avi files into .mpg files that can be fed
# to dvdauthor to create dvd's that will play perfectly on nearly
# all NTSC dvd players and analog/digital televisions.
#
# A special feature of this script is the overscan compensation
# based on laborious trial and error. Because I went to this
# trouble your subtitles and/or supertitles will be visible
# on even the most badly overcompensated television screen, but
# you will not see deformed edges on a television that has 'normal'
# overscan.
#
#
# NOTE: This script takes it's input filenames from the
#       command line. Globbing is permitted, i.e.:
#
#         ./avitovob *.avi
#       or
#         ./avitovob file1.avi file2.avi ...
#
# This script requires transcode, mplayer, sox, and toolame.
#
# Performance on my 2.8 GHz system is 30-40 fps conversion.
#
# copyright 2004 Phil Ehrens <phil@slug.org>
#
# This script is licensed for public use as described here:
# http://www.gnu.org/licenses/gpl.txt
#
# Valuable contributions by Adam Di Carlo <adam@onshored.com>
# The current version of this script can always be found at:
# http://inferno.slug.org/cgi-bin/wiki?AviToVob
# ***************************************************************

# this block writes out the ffmpeg.cfg file with some
# possibly useful values.
#
# The trell option slows encoding down significantly,
# but is a big quality boost. You can also add:
# cmp = 3
# subcmp = 3
# And quality will increase further, but the speed of
# encoding will be VERY slow.
#
# Note that the lines in this
# block must begin in text column zero or the script
# will exit at this point!


cat > ffmpeg.cfg <<_EOF
[mpeg2video]
mbd = 2
trell = 1
vqcomp = 0.7
vqblur = 0.3
_EOF

# We now support ntsc and pal

DVD_TYPE=pal

# Common export aspect ration for all files. 4:3=2 16:9=3

EXPORT_ASR=2

# the -j option here is intended to account for a phenomenon
# of the NTSC standard and analog TV sets called 'overscan'.
# the black borders created by this option will generally NOT
# be visible when viewing on a TV, since they are outside of
# the effective picture area.
#
# There is an additional interesting side effect of -j that can
# be exploited. Using values that are *not* mod(8) seems to
# *improve* the output quality quite a bit.
# Try using -j -18,-34,-22,-34.
# For letterboxed source with ASR 4:3, use -j -8,-34,-8,-34.
# Using non mod(8) values will slow down transcoding by about
# 20%.
# -----------------------------------------------------------
# If you see strange colors or noise at the top and bottom
# of the source video, consider adding --pre_clip 4,0,4,0.
# This is particularly useful for rescuing bad rips from VHS.
#
# Note that the -j top and bottom values should be made
# larger (i.e., from -18 and -22 to -22 and -26) when using
# --pre_clip to maintain aspect ratio.
# -----------------------------------------------------------

OVERSCAN_COMPENSATION="-j -16,-36,-16,-36"

# Which audio stream to use from mkv and ogm file

AUDIO_INDEX=1

# Which subtitle stream to use from mkv and ogm files

SUBTITLE_INDEX=1

# Script will loop over input file(s) on the command line.
# Input files are never deleted. 

[ ! -z "$1" ] && files="$@";

for arg in $files ;

do

# strip the .avi, .mkv, .mov, mp4, or .ogm file extension.

file=`echo $arg | ${SED-sed} -e 's/\.[amo][vkgop][ivm4]$//'`
ext=`echo $arg | ${SED-sed} -e 's/^.*\.//'`

# test for file existence

if [ ! -f "$file.$ext" ];

then

echo "file '$file.$ext' doesn't exist" >&2
exit 1

fi

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## New input handling code!
##
probedata=`mplayer -vo null -ao null -frames 0 -identify "$arg" 2>/dev/null \
           |grep ID_VIDEO`

eval "$probedata";

geometry=${ID_VIDEO_WIDTH}x$ID_VIDEO_HEIGHT;
asr=0;
framerate=$ID_VIDEO_FPS;
index=0;
[ $framerate = 23.976 ] && index=1;
[ $framerate = 25     ] && index=3;
[ $framerate = 29.970 ] && index=4;

asr=`bc -l << _EOF
define asr(w,h) {
if (w/h >= 2.0) return (4);
if (w/h >= 1.6) return (3);
if (w/h >= 0.0) return (2);
}
asr($ID_VIDEO_WIDTH,$ID_VIDEO_HEIGHT)
_EOF
`

probedata="-g $geometry --import_asr $asr -f $framerate,$index"

avi () {
  MPLAYER_OPTS=""
  probedata=""
}

mp4 () {
   MPLAYER_OPTS=""
}

mov () {
   MPLAYER_OPTS=""

}

# we use the same naming convention as ogm so we can clean up
# Use mkvmerge -i $arg and mkvinfo -v $arg to choose the audio
# and/or subtitle stream.
mkv () {
   mkvextract tracks $arg 3:$file.mkv-t1.ass
   MPLAYER_OPTS="=\"-sub $file.mkv-t${SUBTITLE_INDEX}.ass\""
   # If the container has vobsub titles you need to do this
   #MPLAYER_OPTS="=\"-vobsub $file -vobsubid 0\""
}

# use ogminfo to get audio and subtitle stream info
ogm () {
   ogmdemux $arg
   MPLAYER_OPTS="=\"-sub $file.ogm-t${SUBTITLE_INDEX}.srt\""
} 

# execute the type spec
${ext};
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# --------------------------------------------------------------
# At this point you can extract and make use of an existing
# 5.1 channel ac3 audio track by doing this and skipping all
# of the audio processing steps between here and the transcode
# invocation:
#
#        tcextract -i $arg -x ac3 > $file.ac3
#
# If you are doing this, remove the -p, -b, and -m options from
# the transcode invocation, and replace the word "raw" in the -x
# option with the word "null".
# --------------------------------------------------------------
#
# dump the audio to a .wav file using mplayer. You may need to use
# the -aid option if your source has multiple audio tracks.

echo ""
echo "**********************************************************"
echo "If mplayer crashes now it's because you have a very recent"
echo "version that no longer supports the '-vc dummy' option."
echo "please change the line to use '-vc null' if it crashes!"
echo ""
echo "     - thanks to Curt Howland for the heads-up on this!"
echo "**********************************************************"
echo ""
echo "" 

mplayer -ao pcm \
        -vo null \
        -vc dummy \
        $arg > /dev/null 2>&1

# if the sound turns out to be 8 bit, then sox needs
# extra options to handle it correctly.
# thanks to Kenneth Stailey for this patch!

file audiodump.wav | ${GREP-grep
-a
--line-buffered
--color=auto} -qs 'PCM, 8 bit'
if [ $? = 0 ]; then
   B=-b
   W=-w
else
   B=
   W=
fi

# if the incoming sound is not sampled at 48 KHz, we
# upsample the sound to 48000.
# We handle the fact that sox will abort if the input
# frequency is 48000. Note that if it aborts, there will
# be a stub 44 byte long output.wav file to clean up.

if sox $B audiodump.wav -r 48000 $W output.wav resample ; then
   mv -f output.wav audiodump.wav 
else

# otherwise sound was already 48 KHz

   rm -f output.wav
fi

# if converting from 30 fps to 25 fps, you may need to use '-I 3'
[ $DVD_TYPE = "pal" ] && DVD_OPTS="--export_fps 25,3"
[ $DVD_TYPE = "ntsc" ] && DVD_OPTS="--export_fps 29.970,4 \
                                   -Z 720x480,fast \
                                   $OVERSCAN_COMPENSATION"

# first, make sure no zombie named pipe is hanging around

 rm -f stream.yuv

# -----------------------------------------------------------
# When encoding ANIMATED material, adding the temporal
# denoiser using the option '-J hqdn3d' will produce
# significant improvements in image quality and an
# impressive decrease in file size. In some cases it means
# the difference between getting 6 episodes on a dvd versus
# 10! The quality will actually be BETTER!
#
# Note the gamma boost option '-G 0.9'. This is used to
# restore the depth and contrast to material that is
# washed out or has otherwise lost it's "punch". If things
# still look washed out, try using 0.8. If things come out
# too dark using the default 0.9, remove the option.
# -----------------------------------------------------------
# Example of how to hard code vobsubs with .sub and .idx
# files:
#
# -x mplayer="-vobsub $file -vobsubid 0",raw \
#
# Similarly, the -sid option can be used to choose a soft
# subtitle stream from a .ogm or .mkv sourcefile.
# -----------------------------------------------------------
# When ALL the files are 16:9 aspect ratio, you can set the
# --export_asr to '3', and use -j -16,-36,-16,-36. This will
# result in a slight quality improvement.
# -----------------------------------------------------------
# To create a 2-pass invocation (for huge quality improvement)
# simply make two identical calls to transcode, but with the options
# '-R 1,2pass.log' and '-R 2,2pass.log' in the respective
# invocations.

transcode --nice 20 \
          --print_status 500 \
          -G 0.9 \
          -J modfps=clonetype=3 \
          -x mplayer$MPLAYER_OPTS,raw \
          $probedata \
          -y ${FFMPEG-ffmpeg} \
          -p audiodump.wav \
          --import_asr $EXPORT_ASR \
          --export_asr $EXPORT_ASR \
          --export_prof dvd-$DVD_TYPE \
          $DVD_OPTS \
          -o $file \
          -m $file.ac3 \
          -i $arg

rm -f stream.yuv *.wav *.ogm-* *.mkv-*

# mplex supports constant sync offset correction.
# '-O -300ms' would, for example, start audio 300 ms
# earlier than otherwise.

mplex -f 8 -o "$file.mpg" "$file.m2v" "$file.ac3"

rm -f *.m2v *.ac3 ;

# now you have .mpg files, all ready for dvdauthor.
# like so:
#
#        dvdauthor -t -o mydvd \
#                  -c 0,11:30 file_01.mpg \
#                  -c 0,11:30 file_02.mpg \
#                  -c 0,11:30 file_03.mpg
#
#        (and possibly -v ntsc+4:3+720xfull if you get errors
#        and want to be certain that nothing funny happens.)
#
#        dvdauthor -T -o mydvd
#
#        mkisofs -dvd-video -o mydvd.dvd.iso mydvd
#        growisofs -dvd-compat -Z /dev/dvd=mydvd.dvd.iso

done

# end of script

