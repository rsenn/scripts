SHARED=@HOME@/etc

. $SHARED/conf
. $SHARED/functions

SERVICE=/service
CONFDIR=$ETC/daemontools

usage() {
cat <<EOF
Usage: daemontools-conf [-h] [-l] [-t] <cmd> <type> <name>
  where      -h: this help
             -l: make log dir (make command)
             -t: make Makefile for tcp.cdb (make command)
	     -n: dry run (make command)
          <cmd>: make | add | del | enab | disab | list | update | remove
         <type>: type of service (eg. dnscache, smtpd, clockspeed, etc)
         <name>: name of service (eg. inner, local, outer, etc)
EOF
	exit;
}

uidcheck 0 || die 'Only root can run daemontools-conf.'
while test "$#" != "0"; do
	test "$1" = "-h" -o "$1" = "--help" && usage
	if test "$1" = "-l"; then LOG=1; shift
	elif test "$1" = "-t"; then TCP=1; shift
	elif test "$1" = "-n"; then DRY=1; shift
	else break
	fi
done

CMD=$1
TYPE=$2
NAME=$3

test -z "$CMD" -o "$CMD" != "list" -a -z "$TYPE" && usage

if test -z "$NAME"; then
	BASEDIR="$TYPE"
else
	BASEDIR="$TYPE-$NAME"
fi

test -d $CONFDIR || mkdir -p $CONFDIR

case $CMD in

	add)
		test ! -d "$CONFDIR/$BASEDIR" && die "$BASEDIR does not exists"
		ln -s "$CONFDIR/$BASEDIR" $SERVICE 2>/dev/null || die "$BASEDIR is already in services"
		echo "$BASEDIR service added"
		if test ! -z "$NAME" -a ! -L "$ETC/$TYPE"; then
			echo "Creating symlink from $CONFDIR/$BASEDIR to $ETC/$TYPE"
			ln -s "$CONFDIR/$BASEDIR" "$ETC/$TYPE" 2>/dev/null
		fi
		;;

	update)
		if test -L "$CONFDIR/$BASEDIR/Makefile" -a "`linkname $CONFDIR/$BASEDIR/Makefile`" != "$SHARED/tcpmakefile"; then
		    rm $CONFDIR/$BASEDIR/Makefile
		    ln -s $SHARED/tcpmakefile $CONFDIR/$BASEDIR/Makefile
		fi
		if test -L "$CONFDIR/$BASEDIR/log/run" -a "`linkname $CONFDIR/$BASEDIR/log/run`" != "$SHARED/logrun"; then
		    rm $CONFDIR/$BASEDIR/log/run
		    ln -s $SHARED/logrun $CONFDIR/$BASEDIR/log/run
		fi
		;;

	del)
		test -L "$SERVICE/$BASEDIR" || die "$BASEDIR is not in services already"
		if test -L $ETC/$TYPE; then
			origetc=`linkname $ETC/$TYPE`
			if test "$origetc" = "$CONFDIR/$BASEDIR"; then
				rm -f $ETC/$TYPE
				echo "$ETC/$TYPE link deleted"
			fi
		fi
		rm "$SERVICE/$BASEDIR" && echo "$BASEDIR service deleted"
		test -d "$CONFDIR/$BASEDIR/log" && svc -dx $CONFDIR/$BASEDIR/log
		svc -dx $CONFDIR/$BASEDIR
		;;

	make)
		echo "$CONFDIR/$BASEDIR"
		test "$DRY" = "1" && exit 0
		test -d $CONFDIR/$BASEDIR || mkdir -p $CONFDIR/$BASEDIR
		touch "$CONFDIR/$BASEDIR/down"
		if test "$LOG" = "1"; then
			test -d $CONFDIR/$BASEDIR/log || mkdir $CONFDIR/$BASEDIR/log
			touch $CONFDIR/$BASEDIR/log/down
			test -e $CONFDIR/$BASEDIR/log/run || ln -s $SHARED/logrun $CONFDIR/$BASEDIR/log/run
		fi
		if test "$TCP" = "1"; then
			test -e $CONFDIR/$BASEDIR/Makefile || ln -s $SHARED/tcpmakefile $CONFDIR/$BASEDIR/Makefile
			test -e $CONFDIR/$BASEDIR/tcp || echo ":deny" > $CONFDIR/$BASEDIR/tcp
			test -e $CONFDIR/$BASEDIR/tcp.cdb || make -C $CONFDIR/$BASEDIR
		fi
		;;

	enab*)
		test -L "$SERVICE/$BASEDIR" || die "$BASEDIR is not supervised yet."
		test -f "$SERVICE/$BASEDIR/down" || die "$BASEDIR was not disabled."
		rm -f "$SERVICE/$BASEDIR/down" "$SERVICE/$BASEDIR/log/down"
		test -d "$SERVICE/$BASEDIR/log" && svc -u $SERVICE/$BASEDIR/log
		svc -u $SERVICE/$BASEDIR
		echo "$BASEDIR enabled."
		;;

	disab*)
		test -L "$SERVICE/$BASEDIR" || die "$BASEDIR is not supervised yet."
		test -f "$SERVICE/$BASEDIR/down" && die "$BASEDIR was disabled already."
		touch "$SERVICE/$BASEDIR/down"
		svc -d $SERVICE/$BASEDIR
		if test -d "$SERVICE/$BASEDIR/log"; then
			touch "$SERVICE/$BASEDIR/log/down"
			svc -d $SERVICE/$BASEDIR/log
		fi
		echo "$BASEDIR disabled."
		;;

	list)
		test -z "$TYPE" && TYPE="*"
		test -z "$NAME" && NAME="*"
		for i in `ls -d $CONFDIR/$TYPE-$NAME`; do
			tname=`basename $i`
			type=`echo $tname|cut -d- -f1`
			echo -en "\t$tname"
			test -L "$SERVICE/$tname" || echo -n " (not supervised)"
			test -L "$ETC/$type" -a "`linkname $ETC/$type`" = "$i" && echo -n " (main service)"
			echo
		done
		;;

	remove)
		test -d "$CONFDIR/$BASEDIR" || die "$BASEDIR is not configured yet."
		test -L "$SERVICE/$BASEDIR" && $0 del "$TYPE" "$NAME"
		rm -r "$CONFDIR/$BASEDIR" && echo "$BASEDIR frame removed."
		;;

	*)	echo "Unknown command $CMD."
		usage
		exit 1
		;;
esac
