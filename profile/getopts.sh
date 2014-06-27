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
# $Date: 2008-06-08 18:02:22 +0300 (Sun, 08 Jun 2008) $
# $Author: hai-zaar $
#
# This bash library implements the function getopt_long.
# This function is used to parse command line parameters.
# There are two types of command line parameters:
#	Flag parameters  - Have no value after them, They are either on or of.
#	Value parameters - Have a value after them.
#						  If no value is give after this kind of parameter,
#						  a NULL value will be assined, and an error will be show.
# NOTE: If -a is a value parameter, and you will run <command> -a -b,
#		-b will be assined as the value of -a. Moreover, it will not be treated as
#		a flag/value parameter in this case.

#-------------------------------------------------------------------------
#EXPORT=getopt_long
#REQUIRE=hashSet hashGet
#-------------------------------------------------------------------------

###############################################################
##################    SERVICE  FUNCTIONS    ###################
###############################################################
#
# $retval parseParams <OptsString> <Instructions> <Rest-Of-The-Parameters> (internal)
#
#	This function goes over the parameters and creates a string that contains
#	variables definitions. If there's a value after the letter parameter, it
#	will be given to it. Else, a "1" will be set.
#	Example: For instructions="h Help p Path", OptsString="hp:",
#	when the parameters are  --help --path "/etc/",
#	it will return Help=1; Path=/etc/;
#
#	Parameters:
#		OptsString
#			A string that contains parameter letter in getopt(1) format.
#			If a parameter should have a value after it, its letter will
#			be followed by ":".
#			Example: For the parameters -h and -p <path>, the string will be "hp:"
#			See getopt(1) man page for more info
#
#		Instructions
#			These are the parsing instructions in their last version. \n
#			They must be in the form: -<letter> <var-name>
#
#		Rest-Of-The-Parameters
#			This is the rest of the $* of this function (we'll call shift).
#			getopt(1) always works on $*, so it will work on these.
#
#	Return value:
#		A string that contains a set of variable definitions. \n
#		Those variable definitions will become variables, \n
#		if the calling progam will run \c eval on the return value.
#
__getopts_parseParams()
{
	local GotError=0
	local Params=""
	local OptsString=$1
	Instructions=($2)
	local HashName=GivenParameters
	shift 2

	while getopts "$OptsString" Param ; do
		[[ $Param == "?" ]] && GotError=1 && continue
		retval=""
		hashGet $Param $HashName 1>/dev/null 2>&1
		# Build a hash of the options given
		hashSet "$retval ${OPTARG:-1}" $Param $HashName
	done

	for VarIndex in `seq 1 2 ${#Instructions[*]}`; do
		let OptionIndex=${VarIndex}-1
		local Option=${Instructions[OptionIndex]}
		local CurrVarName=${Instructions[VarIndex]}

		# Get the option from the hash
		hashKeys $HashName
		if [[ "$retval" = *" $Option "* ]] ; then
			retval=""
			hashGet $Option $HashName
			if [[ $retval ]] ; then
				Params="$Params $CurrVarName='$retval';"
			fi
		fi
	done

	retval=$Params
	return $GotError
}

#
# $retval createSingleCharParams <Instructions> <Params> (internal)
#
#	This function translates the parameters. That is, any multi-letter parameter name will be
#	replaced by it's single-letter name.
#
#	Parameters:
#		Instructions
#			These are the parsing instructions in their last version.
#			They must be in the form:
#				-<single-letter-name>|--<multi-letter-name>-><variable-name>
#
#		Params
#			The params to translate
#
#	Return value:
#		The parameters, using only single-letter options.
__getopts_createSingleCharParams()
{
	local ParsingInstructions=$1
	shift
	local Params="$@"
	local ParsedParams=""

	for curr_param in $Params ; do
		# Go over the parsing instructions
		for Instruction in $ParsingInstructions ; do
			# Find the names of the paremeter (exaample: -h|--help)
			CurrParamName="${Instruction%->*}"

			# Find the single-letter parameter that must be first (exaample: -h)
			SingleLetterName="${CurrParamName%|*}"

			# Find the multi-letter parameter that must be second (exaample: --help)
			MultiLetterName="${CurrParamName#*|}"

			# Replace the multi letter parameter that has `=' after it with a single letter parameter
			# that has a ` ' after it.
			curr_param="$(sed -e "s/^$MultiLetterName\(=\|$\)/ $SingleLetterName /g" <<< $curr_param)"
		done
		ParsedParams="$ParsedParams $curr_param"
	done

	retval="$ParsedParams"
}

#
# $retval[2] buildGetOptsData <Instructions> (internal)
#
#	This function builds the data needed for getopts (See return values).
#
#	Parameters
#		Instructions
#			These are the parsing instructions in their last version.
#			They must be in the form:
#				-<single-letter-name>|--<multi-letter-name>-><variable-name>
#
#	Return value:
#		An array with two values, where:
#		Index0 - The optsring needed for the bash builtin getopts (See man bash).
#		Index1 - Translated instractions. That is, the same instructions, presented as a sequense of
#				 couple. The first value in a couple is the parameter single-letter name.
#				 The second is the variable name for the value of that parameter.
__getopts_buildGetOptsData()
{
	local ParsingInstructions="$@"
	local Instructions=""
	local OptsString=""

	# Go over the parsing instructions
	for Instruction in $ParsingInstructions ; do
		# Find the single-letter parameter that must be first (exaample: h)
		local SingleLetterName=${Instruction%|*}
		SingleLetterName=${SingleLetterName#*-}

		# Add the 1 letter name to the opts-string
		OptsString=${OptsString}${SingleLetterName}

		# Find the name of the wanted variable name, that comes after a '=' (example: h|help->Help)
		local WantedVarName=${Instruction#*->}

		# Check if the parameter should have a following value
		# A ':' at the end of it's name indicates that (example: -p|--path->Path:)
		if [[ "$WantedVarName" = *: ]] ; then
			# Add the ':' to the OptsString
			OptsString="${OptsString}:"

			# Remove the ':' from the variable name
			WantedVarName=${WantedVarName%:*}
		fi

		Instructions="${Instructions}${SingleLetterName} ${WantedVarName} "
	done

	retval=("$OptsString" "$Instructions")
}

##############################################################
###################    MAIN  FUNCTIONS    ####################
##############################################################
#
# $retval getopt_long <ParsingInstructions> <Params>
#
#	Intented to parse command line parameters.
#
#	Parameters:
#		ParsingInstructions
#			The instructions for parsing
#			Each instruction is in the form of:
#				<single-letter parameter>|<long parameter>-><Variable name>[:]
#			For example: -h|--help->Help
#			The ':' after variable name indicates that the variable must have
#			value, otherwise variable is flag (is set to 1 if exists and 0 otherwises).
#
#		Params
#			The parameters to parse (usually from command line).
#
#	Return value:
#		A string that contains variables definitions, according to the parameters.
#		This string should be evaluated (eval $retval).
#		The return value is set to the variable name $retval.
#		For example, when the <ParsingInstructions> are  -h|--help->Help -p|--path->Path:,
#		and <Params> are -h --path=/etc/,
#		it will return  'Help=1; Path=/etc/;'
#		When a value parameter apears more than once an array is created. That is, if
#		<ParsingInstructions> are  -h|--help->Help -p|--path->Path:, and <Params> are
#		-h --path=/etc/ --path=/bin
#		it will return 'Help=1; Path=( /etc /bin );'
#
getopt_long()
{
	local GotError=0
	ParsingInstructions=$1
	shift

	local Params=""
	for param in "$@" ; do
		# Replace spaces with "__getopts__". This makes it much easier to handle the values.
		Params="$Params ${param// /__getopts__}"
	done

	__getopts_createSingleCharParams "$ParsingInstructions" $Params
	Params=$retval

	__getopts_buildGetOptsData $ParsingInstructions

	__getopts_parseParams "${retval[0]}" "${retval[1]}" $Params

	# Step by step:
	# 1. Replacing the first "=' " with "=('"
	#	 This starts an array using ( and starts the first string using "'"
	# 2. Replacing each splace with a "' '". At this point spaces will be
	#	 only between two values. This terminated the first string, and starts
	#	 the next one.
	# 3. Replace any "__getopts__" with a space. This puts the spaces we removed
	#	 before back in place.
	# 4. Replacing the ";" with ");". This way we close the array, and end the
	#	 current command.
	retval="$(echo $retval | sed -e "s/=' /=('/g" \
								 -e "s/; */;/g" \
								 -e "s/ /' '/g" \
								 -e "s/__getopts__/ /g" \
								 -e "s/;/);/g")"

	return $GotError
}
