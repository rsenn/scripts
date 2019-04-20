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
# Very simple library to help printing message in format similar
# to init scripts
#

#-------------------------------------------------------------------------
#EXPORT=printOK printFAIL printNA printATTN
#REQUIRE=colorPrint
#-------------------------------------------------------------------------

#
# __messages_calculateShift
#	Calculate tty width (X) and reports X-10. If its unable to
#	determite tty width (for example, in case of serial console),
#	returns 80-10
#
#	Return value:
#		number of columns to move to
#
__messages_calculateShift() {
	local ttyXxY=$(stty size 2>/dev/null)
	local ttyX=${ttyXxY##* }
	# When using remote connections, such as a serial port, stty size returns 0
	if [ "$ttyX" = "0" ]; then ttyX=80; fi
	let "ttyX = ttyX - 10"
	retval=$ttyX
}

#
# __messages_print <COLOR> <TEXT> <INDENT>
#
#	Prints TEXT in the color COLOR in the column INDENT.
#
#	Parameters:
#		COLOR	- The color for the tty print.
#		TEXT	- The text to be printed in the color COLOR.
#		INDENT	- The column that the message will be printed in.
__messages_print()
{
	local COLOR=$1
	local TEXT=$2
	local INDENT=$3
	echo -en "\\033[${INDENT}G["

	case ${#TEXT} in
		0)	echo -en "    "	;;
		1)	echo -en "  "	;;
		2)	echo -en " "	;;
		3)	echo -en " "	;;
		*)	echo -en
	esac

	colorPrint $COLOR $TEXT

	case ${#TEXT} in
		1)	echo -en " "	;;
		2)	echo -en " "	;;
		*)	echo -en
	esac

	echo -e "]"
}

#
# printOK printOK [INDENT]
#
#	Prints an OK message.
#
#	Parameters:
#		INDENT
#			The column that the message will be printed in.
#			This parameter is optional. If not given, a default value (60) is assined.
printOK()
{
	__messages_calculateShift
	local SHIFT=$retval
	__messages_print GREEN "OK" ${1:-$SHIFT}
}

# printFAIL printFAIL [INDENT]
#
#	Prints an FAIL message.
#
#	Parameters:
#		INDENT
#			The column that the message will be printed in.
#			This parameter is optional. If not given, a default value (60) is assined.
printFAIL()
{
	__messages_calculateShift
	local SHIFT=$retval
	__messages_print RED "FAIL" ${1:-$SHIFT}
}

# printNA printNA [INDENT]
#
#	Prints an N/A message.
#
#	Parameters:
#		INDENT
#			The column that the message will be printed in.
#			This parameter is optional. If not given, a default value (60) is assined.
printNA()
{
	__messages_calculateShift
	local SHIFT=$retval
	__messages_print YELLOW "N/A" ${1:-$SHIFT}
}

# printATTN printATTN [INDENT]
#
#	Prints an ATTN message.
#
#	Parameters:
#	INDENT
#		The column that the message will be printed in.
#		This parameter is optional. If not given, a default value (60) is assined.
printATTN()
{
	__messages_calculateShift
	local SHIFT=$retval
	__messages_print YELLOW "ATTN" ${INDENT:-$SHIFT}
}

# printWAIT printWAIT [INDENT]
#
#	Prints an WAIT message.
#
#	Parameters:
#		INDENT
#			The column that the message will be printed in.
#			This parameter is optional. If not given, a default value (60) is assined.
printWAIT()
{
	__messages_calculateShift
	local SHIFT=$retval
	__messages_print YELLOW "WAIT" ${INDENT:-$SHIFT}
}
