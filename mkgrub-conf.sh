IFS="
 "

#ARGS="edd=off keymap=sg-latin1 livemedia load_ramdisk=1 loglevel=9 lowram max_loop=256 noacpid nobluetooth nodmeventd noeject nofstabdaemon nogpm nohal nolvm nonfs nontpd nosmart nosound nosshd nowicd prompt_ramdisk=0 rw vga=normal vmalloc=288MiB de_CH xvesa"

DONE=''
ARGS="edd=off
load_ramdisk=1
max_loop=256
nobluetooth
noeject
nogpm
nonfs
nontpd
nosshd
keymap=sg-latin1
de_CH
"

THISDIR=${1:-` dirname "$0"`}
KERN_IMGS=` ls -d bzImage*` 

var_s=" "
cr='' lf=$'\n' ht=$'\t' vt='' squote="'" sq="'"

isin () 
{ 
    ( needle="$1";
    while [ "$#" -gt 1 ]; do
        shift;
        test "$needle" = "$1" && exit 0;
    done;
    exit 1 )
}

str_escape () 
{ 
    local s=$1;
    case $s in 
        *[$cr$lf$ht$vt'€']*)
            s=${s//'\'/'\\'};
            s=${s//'
'/'\r'};
            s=${s//'
'/'\n'};
            s=${s//'	'/'\t'};
            s=${s//''/'\v'};
            s=${s//''\'''/'\047'};
            s=${s//''/'\001'};
            s=${s//'€'/'\200'}
        ;;
        *$sq*)
            s=${s//"\\"/'\\'};
            s=${s//"\""/'\"'};
            s=${s//"\$"/'\$'};
            s=${s//"\`"/'\`'}
        ;;
    esac;
    echo "$s"
}


str_quote() 
{ 
    case "$1" in 
        *["$cr$lf$ht$vt"]*)
            echo "\$'`str_escape "$1"`'"
        ;;
        *"$squote"*)
            echo "\"`str_escape "$1"`\""
        ;;
        *)
            echo "'$1'"
        ;;
    esac
}

var_dump() 
{ 
    ( for N in "$@";
    do
        N=${N%%=*};
        O=${O:+$O${var_s-${IFS%${IFS#?}}}}$N=`eval 'str_quote "${'$N'}"'`;
    done;
    echo "$O" )
}

mountpoint-for-file()
{ 
  df "$1" | sed 1d | awk '{ print $6 }'
}

MOUNTPOINT=`mountpoint-for-file "$THISDIR"` 

get_arch()
{
   BASE=${1##*/}
   BASE=${BASE%.*}

   case "$BASE" in
      *64|*64-*) echo "x86_64" ;;
      *-i[34567]86 | *-x86_64) echo "${BASE##*-}" ;;
   esac
}

skip()
{
  echo "Skipping $@ ..." 1>&2
}

for KERN_IMG in $KERN_IMGS; do

  VER="${KERN_IMG#bzImage}"
  ARCH=
  BITS=
  INITRD_ARCH=
  
 


  if [ "$VER" != "${VER#64-}" ]; then ARCH=x86_64 BITS=64 VER=${VER#64-}
  elif [ "$VER" != "${VER#64}" ]; then ARCH=x86_64 BITS=64 VER=${VER#64-}
  fi
  VER=${VER#-}
  #[ "$VER" != "${VER%-i[3-6]86}" -o "$VER" != "${VER%-x86_64}" ] && ARCH=${VER##*-} VER=${VER%-i?86} 

  [ -z "$ARCH" ] &&
  ARCH=`get_arch "${KERN_IMG#bzImage}"`

  VER=${VER%"-$ARCH"} 
  VER=${VER%64}
  VER=${VER%64-*}
  
  test -n "$VER" || { skip "$KERN_IMG (1)"; continue; }
 
 INITRD_IMG_MASK="${ARCH:+initr*$VER*${ARCH//[-_]/*}*
}initr*$VER*"


 INITRD_IMGS=`set -f; set -- $INITRD_IMG_MASK; for MASK; do set +f; ls  -1 -d -- $MASK && break; done  2>/dev/null |sort -r`

 echo INITRD_IMGS=$INITRD_IMGS 1>&2
 set -- $INITRD_IMGS
 test -e "$1" || { skip "Initial ramdisk for $KERN_IMG not found [Mask: $INITRD_IMG_MASK] (2)"; continue; }

 while :; do
 INITRD_IMG="$1"
 INITRD_NAME="${INITRD_IMG%.img}"

   INITRD_ARCH=`get_arch $INITRD_NAME`
#   
    test -n "$INITRD_IMG" -o "$ARCH" = "$INITRD_ARCH" && break
   shift
 done
#  var_dump ARCH VER KERN_IMG INITRD_IMG 1>&2
test -n "$INITRD_IMG" || { skip "No initrd image (Mask was $INITRD_IMG_MASK) (3)" ; continue; }
#  test -e "$INITRD_IMG" || { skip "$INITRD_IMG (3)" ; continue; }


 KEY="${VER}${ARCH:+-$ARCH}"

 isin "$KEY" $DONE && continue
 
 DONE="${DONE:+$DONE
}$KEY"


#   var_dump ARCH VER  1>&2
 KERN_FILE="/pmagic/${KERN_IMG}"
 INITRD_FILE="/pmagic/${INITRD_IMG}"

VERMASK=$(echo "$VER"|sed 's,\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\),\1*\2*\3,')

SQFSLIST=$(ls -d pmodules/*$VERMASK*.{SQFS,sqfs} 2>/dev/null)
set -- $SQFSLIST

test -e "$1" || { skip "No sqfs for $VER (4)" ; continue ; }

 set -- $ARGS


 echo title PartedMagic v$VER ${ARCH:+($ARCH)}
[ "$ROOT" ] && echo root "$ROOT"
 echo kernel $KERN_FILE $ARGS
echo initrd $INITRD_FILE 
echo

 done
