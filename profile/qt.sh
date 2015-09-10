# Qt initialization script (sh)

# In multilib environments there is a preferred architecture, 64 bit over 32 bit in x86_64,
# ppc64. When a conflict is found between two packages corresponding with different arches,
# the installed file is the one from the preferred arch. This is very common for executables
# in /usr/bin, for example. If the file /usr/bin/foo is found  in an x86_64 package and in
# an i386 package, the executable from x86_64 will be installe

#if [ -z "${QTDIR}" ]; then

  QTCLANG=true

	case `uname -m` in
		 x86_64 | ia64 | s390x | ppc64 | ppc64le)
			 QT_PREFIXES="$( dirname /opt/Qt*/[0-9]*/*/bin | sort -r -V | grep 64 )
/usr/lib64/qt-3.3
/usr/lib/qt-3.3" ;;
		 * )
				QT_PREFIXES="$( dirname /opt/Qt*/[0-9]*/*/bin | sort -r -V | grep -v 64 )
/usr/lib/qt-3.3
/usr/lib64/qt-3.3" ;;
	esac

	if [ "$QTCLANG" = true ]; then
		QT_PREFIXES=$(grep clang <<<"$QT_PREFIXES" )
	fi

	for QTDIR in ${QT_PREFIXES} ; do
		test -d "${QTDIR}" && break
	done
	unset QT_PREFIXES

	if ! echo ${PATH} | grep -q $QTDIR/bin ; then
		 PATH=$QTDIR/bin:${PATH}
	fi

	QTCREATORDIR=${QTDIR%%/[0-9].*}
	[ "$QTCREATORDIR" != "$QTDIR" ] && QTCREATORDIR="$QTCREATORDIR/Tools/QtCreator"
  if [ -d "$QTCREATORDIR" ]; then
		if ! echo ${PATH} | grep -q $QTCREATORDIR/bin ; then
			 PATH=$QTCREATORDIR/bin:${PATH}
		fi
	fi
	unset QTCREATORDIR

	QTINC="$QTDIR/include"
	QTLIB="$QTDIR/lib"

	export QTDIR QTINC QTLIB PATH

#fi
