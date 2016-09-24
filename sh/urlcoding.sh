# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#               Do not run this script directly!
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#############################################################################
# Copyright (c) 2005 Alon Keren												#
#																			#
# This program is free software; you can redistribute it and/or modify it	#
# under the terms of version 2 of the gnu general public license as			#
# published by the Free Software Foundation.								#
#																			#
#############################################################################
#
# $Date: 2006-07-31 09:40:21 +0300 (Mon, 31 Jul 2006) $
# $Author: haizaar $
#
# This library provides functions for conversion between ASCII-text and standard URL's.
# AWK code is based on code by Heiner Steven <heiner.steven@odn.de>.
#

#--------------------------------------------------------------------------------------------------
#EXPORT=urlEncodeStream urlEncodeString urlEncodeFile urlDecodeStream urlDecodeString urlDecodeFile
#REQUIRE=
#--------------------------------------------------------------------------------------------------

###############################################################
##################    LIBRARY CONSTANTS    ####################
###############################################################
__urlcoding_AWK="awk"
__urlcoding_USAGE_ERROR="1"
__urlcoding_SUCCESS="0"


###############################################################
##################    SERVICE  FUNCTIONS    ###################
###############################################################
#
# $retval[2] getParams <Params>
#	Analayze coding parameters from function-arguments.
#
#	Parameters:
#		Params:
#			The arguments with which an exported function was called.
#
#	Return value: (Source EncodeEOLflag)
#		An array comprised of the following:
#			Index0 - The data source parameter
#			Index1 - the '-l' flag, if given
#
#	Exit status:
#		__urlcoding_SUCCESS		-	the run was successful
#		__urlcoding_USAGE_ERROR	-	bad parameters were given
__urlcoding_getParams ()
{
	local EncodeEOLflag=
	local Source=""
	[[ ! $1 ]] && return $__urlcoding_USAGE_ERROR
	
	if [[ "$1" == "-l" ]]; then
		EncodeEOLflag="-l"
		[[ ! $2 ]] && return $__urlcoding_USAGE_ERROR
		Source="$2"
	else
		Source="$1"
	fi
	retval=("$Source" "$EncodeEOLflag")
	return $__urlcoding_SUCCESS
}

##############################################################
###################    MAIN  FUNCTIONS    ####################
##############################################################
#
# urlEncodeString [-l] <STRING>
#
# 	Encode URL from a given string.
#
#	Parameters:
#		-l:
#			Encode line-feed chatacters ('\n') as well
#
#		STRING:
#			The URL to encode
#
#	Return value:
#		None.
#
#	Exit status:
#		See the 'exit status' section of urlEncodeStream
urlEncodeString ()
{
	__urlcoding_getParams "$@" || return $__urlcoding_USAGE_ERROR
	echo "${retval[0]}" | urlEncodeStream "${retval[1]}"
	return $?
}

#
# urlEncodeFile [-l] <FILENAME>
#
# 	Encode text from a file.
#
#	Parameters:
#		-l:
#			encode LF chatacters ('\n') as well
#
#		FILENAME:
#			the path of the file which contains the text to encode
#		
#	Return value:
#		None.
#
#	Exit status:
#		See the 'exit status' section of urlEncodeStream
#
urlEncodeFile ()
{
	__urlcoding_getParams "$@" || return $__urlcoding_USAGE_ERROR
	urlEncodeStream "${retval[1]}" < "${retval[0]}"
	return $?
}

#
# urlDecodeString <STRING>
#
# 	Decode encoded URL from a string.
#
#	Parameters:
#		STRING:
#			URL to decode
#	
#	Return value:
#		None.
#
#	Exit status:
#		See the exit status of urlDecodeStream
#
urlDecodeString ()
{
	[[ "$1" ]] || return $__urlcoding_USAGE_ERROR
	echo "$1" | urlDecodeStream
	return $?
}

#
# urlDecodeFile <FILENAME>
#
# 	Decode encoded text from a file.
#
#	Parameters:
#		FILENAME:
#			the file which contains the encoded text to decode
#
#	Return value:
#		None.
#
#	Exit status:
#		See the exit status of urlDecodeStream
#
urlDecodeFile ()
{
	[[ "$1" ]] || return $__urlcoding_USAGE_ERROR
	urlDecodeStream < "$1"
	return $?
}

#
# urlEncodeStream [-l]
#
#	Encode URL from input stream.
#
#	Parameters:
#		-l:
#			Encode LF chatacters ('\n') as well
#
#	Return value:
#		None.
#
#	Exit status:
#		The exit status of the command $__urlcoding_AWK
urlEncodeStream ()
{
	local EncodeEOL=
	[[ "$1" == "-l" ]] && EncodeEOL=yes
	$__urlcoding_AWK '
	    BEGIN {
			# We assume an awk implementation that is just plain dumb.
			# We will convert an character to its ASCII value with the
			# table ord[], and produce two-digit hexadecimal output
			# without the printf("%02X") feature.
			EOL = "%0A"		# "end of line" string (encoded)
			split ("1 2 3 4 5 6 7 8 9 A B C D E F", hextab, " ")
			hextab [0] = 0
			for ( i=1; i<=255; ++i ) ord [ sprintf ("%c", i) "" ] = i + 0
			if ("'"$EncodeEOL"'" == "yes") EncodeEOL = 1; else EncodeEOL = 0
			previous_line = ""
	    }
	    {
			encoded = ""
			for ( i=1; i<=length ($0); ++i ) {
			    c = substr ($0, i, 1)
			    if ( c ~ /[a-zA-Z0-9.-]/ ) {
					encoded = encoded c		# safe character
			    } else if ( c == " " ) {
					encoded = encoded "+"	# special handling
			    } else {
					# unsafe character, encode it as a two-digit hex-number
					lo = ord [c] % 16
					hi = int (ord [c] / 16);
					encoded = encoded "%" hextab [hi] hextab [lo]
			    }
			}
			# Prints the line encoded in the previous Awk-iteration, so
			# to avoid printing an EOL at the end of the file.
			if ( NR > 1 ) {
				if ( EncodeEOL ) {
				    printf ("%s", previous_line EOL)
				} else {
				    print previous_line
				}
			}
			previous_line = encoded
	    }
		
	    END {
			print previous_line
	    	#if ( EncodeEOL ) print ""
	    }
	'
	return $?
}

#
# urlDecodeStream
#
#	Decode encoded URL from input file.
#
#	Parameters:
#		None.
#
#	Return value:
#		None.
#
#	Exit status:
#		The exit status of the command $__urlcoding_AWK
urlDecodeStream ()
{

	$__urlcoding_AWK '
	    BEGIN {
			hextab ["0"] = 0;	hextab ["8"] = 8;
			hextab ["1"] = 1;	hextab ["9"] = 9;
			hextab ["2"] = 2;	hextab ["A"] = hextab ["a"] = 10
			hextab ["3"] = 3;	hextab ["B"] = hextab ["b"] = 11;
			hextab ["4"] = 4;	hextab ["C"] = hextab ["c"] = 12;
			hextab ["5"] = 5;	hextab ["D"] = hextab ["d"] = 13;
			hextab ["6"] = 6;	hextab ["E"] = hextab ["e"] = 14;
			hextab ["7"] = 7;	hextab ["F"] = hextab ["f"] = 15;
	    }
	    {
	    	decoded = ""
			i   = 1
			len = length ($0)
			while ( i <= len ) {
			    c = substr ($0, i, 1)
			    if ( c == "%" ) {
			    	if ( i+2 <= len ) {
					    c1 = substr ($0, i+1, 1)
					    c2 = substr ($0, i+2, 1)
					    if ( hextab [c1] == "" || hextab [c2] == "" ) {
							print "WARNING: invalid hex encoding: %" c1 c2 | \
							"cat >&2"
					    } else {
					    	code = 0 + hextab [c1] * 16 + hextab [c2] + 0
					    	#print "\ncode=", code
					    	c = sprintf ("%c", code)
						i = i + 2
					    }
					} else {
					    print "WARNING: invalid % encoding: " substr ($0, i, len - i)
					}
			    } else if ( c == "+" ) {	# special handling: "+" means " "
			    	c = " "
			    }
			    decoded = decoded c
			    ++i
			}
		    print decoded
	    }
	'
	return $?
}
