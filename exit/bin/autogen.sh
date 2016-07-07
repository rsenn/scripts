#!/bin/sh
#
# 20080719

libtoolize --force --copy --automake
aclocal --force -I ../m4 -I config
automake --force --copy --foreign --add-missing --foreign
aclocal --force -I ../m4 -I config
autoconf --force
