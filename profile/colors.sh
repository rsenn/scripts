# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#               Do not run this script directly!
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
###########################################################################
# Copyright (c) 2004-2005 Hai Zaar and Gil Ran                            #
#                                                                         #
# This program is free software; you can redistribute it and/or modify it #
# under the terms of version 2 of the GNU General Public License as       #
# published by the Free Software Foundation.                              #
#                                                                         #
###########################################################################
#
# $Date: 2006-07-31 09:40:21 +0300 (Mon, 31 Jul 2006) $
# $Author: haizaar $
#
# Simple library that implements interface for colorfull tty printouts
#

#-------------------------------------------------------------------------
#EXPORT=colorSet colorReset colorPrint colorPrintN
#REQUIRE=
#-------------------------------------------------------------------------

# Internal constants
__colors_GREEN="\\033[1;32m"
__colors_RED="\\033[1;31m"
__colors_YELLOW="\\033[1;33m"
__colors_WHITE="\\033[0;39m"
__colors_DefaultIndent=60


###################
#### FUNCTIONS ####
###################

#
# __colors_ident __colors_ident [INDENT]
#
#	Shifts  curret to INDENT position.
#
#	Parameters:
#		INDENT	- Column to indent to. Defaults to 60.
__colors_ident() 
{
	local DefaultIndent=60
	local INDENT=${1:-$DefaultIndent}
	
	echo -en "\\033[${INDENT}G"
}

#
# colorSet colorSet <COLOR>
#
#	Sets the color of the tty prints to COLOR.
#	
#	Parameters:
#		COLOR	- The new color for tty prints.
colorSet()
{
	eval "local WantedColor=\"\$__colors_$(echo $1 | tr a-z A-Z)\""
	if [[ WantedColor == "" ]] ; then
		echo "colors: Warning: Color $1 is not listed in the colors list." 1>&2
		return 1
	fi
	
	echo -en "$WantedColor"
}

#
# colorReset colorReset
#
#	Resets tty color to normal
#	
colorReset()
{
	#  Reset text attributes to normal
	tput sgr0
}

#
# colorPrint colorPrint [INDENT] <COLOR> <TEXT> 
#
#	Prints TEXT in the color COLOR while shifting curret to INDENT
#	
#	Parameters:
#		COLOR	- The color for the tty print.
#		TEXT	- The text to be printed in the color COLOR.
#		INDENT	- Move curret to INDENT before printing
colorPrint()
{

	# If INDENT parameter given - respect it.
	echo $1 |grep -q '^[0-9][0-9]*$' && __colors_ident $1 && shift
	
	local COLOR=$1
	shift
	colorSet $COLOR || return 1
	echo -en "$@"

	#  Reset text attributes to normal
	tput sgr0
}

#
# colorPrintN colorPrintN [INDENT] <COLOR> <TEXT> 
#	Same as colorPrint but prints trailing \n as well
#
colorPrintN()
{
	colorPrint $*
	echo
}

