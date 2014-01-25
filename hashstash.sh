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
# Set of fuctions that implement hash data structure. 
# Each hash can have both keys and subhashes. 
# WARNING:
#	You can not have key and subhash with the same name. 
#	Its because, we do not have actual data types. I.e. you can call
#	hashGet on hash with its subhash as key - it will return list of subhash's keys.
#
# Hash Variables
#	The hash variable is transparent to the user of these functions. 
#	Such variables should be used only through the functions.
# 	Each "hash variable" holds a list of keys.
# 	For example: The variable for the hash DIR that holds the `keys' `etc' `bin' `lib'
#	will be: _HASH_DIRS_=" etc bin lib "
# 	Notice that before and _after_  every key there must be a white space (can be more then one).
#
# Key Variables
# 	The key value is held in a variable that is named ${HashName}${Key}_. 
#	Note trailing `_') in ${HashName}.
# 	For example: The value of the key `etc' of the hash DIR will be in the variable _HASH_DIRS_etc_.
# 	Notice that this name can also be the name of a hash named DIRS_etc.
#	The key variable is also transparent to the user of these functions. 
#	These variables should be used only through the functions.
#
# Sub-Hashes
#	A sub-hash is a hash key that holds a keys list.
# 	This way, if you set a hash key value to be a list in the suitable form, 
#	it can be used as a "sub hash".
# 	Use of hashSet ensures that the list will be in the right form.

#-------------------------------------------------------------------------
#EXPORT=hashGet hashSet hashKeys hashDelete hashRemove
#REQUIRE=
#-------------------------------------------------------------------------

# The prefix of the hashes variables. 
# NOTE: Do not name any of your variables _HASH_*
PREFIX="__hash_"

#
# DEBUG=1 - If DEBUG will not be commented, debug printouts will be enabled
#DEBUG=1

###################
#### FUNCTIONS ####
###################

#
# hashSet <Value> <Key> <HashName> [SubHashName [...] ]
#
#	Adds a value to the hash. Value will be the value of the key Key in the hash HashName.
#	For example if you have (or want to define) hash C, which is subhash of hash B, 
#	which is subhash of hash A and C has key ckey1 with value cval1, then you should run:
#		hashSet cval1 ckey1 A B C 
#	
#	Parameters:
#		Value		- The value to set in HashName[Key].
#		Key			- The key for the value Value.
#		HashName 
#		[SubHashName [...] ]
#			A string that contains the name of the hash. 
#			If the hash is a sub hash of another hash, the "father hash" 
#			name MUST BE WRITTEN FIRST, followed by the sub-hash name.
hashSet()
{
	local Value=$1
	local Key=$2
	shift 2
	
	# Parse the key variable name ${PREFIX}_${HashName}_${SubHashName}_..._${Key}_
	# Example: For the parameters "VALUE1 KEY1 DIRS ETC ", the variable name will be _HASH_DIRS_ETC_KEY1_
	local ParamsString="$*"
	local HashName=${PREFIX}${ParamsString// /_}_
	local KeyVarName=${HashName}${Key}_

	# Set the value in the key variable
	test $DEBUG && echo eval "$KeyVarName"'="'$Value'"' 1>&2
	eval "$KeyVarName"'="'$Value'"'

	# Check if the key is not in the keys list
	hashKeys $*
	test $DEBUG && echo retval=$retval 1>&2
	if ! [[ $retval = *" $Key "*  ]] ; then
		# Add the key to the keys list
		test $DEBUG && echo eval $HashName'="${'$HashName'}'" $Key "'"' 1>&2
		eval $HashName'=${'$HashName'}"'" $Key "'"'
	fi
}

#
# $retval hashGet <Key> <HashName> [SubHashName [...] ]
#	Returns the value of Key in HashName in the variable $retval.
#	
#	Parameters:
#		HashName 
#		[SubHashName [...] ]
#			A string that contains the name of the hash.
#			If the hash is a sub hash of another hash, the "father hash" 
#			name MUST BE WRITTEN FIRST, followed by the sub-hash name.
#			See hashSet for example.
#	Key
#		The hash key of the value \c Value.
#
#	Return value:
#		The value of the key Key in the hash HashName.
#		The value is returned in the variable $retval.
hashGet()
{
	local Key=$1
	shift
	
	# Parse the key variable name ${PREFIX}_${HashName}_${SubHashName}_..._${Key}_
	# Example: For the parameters "KEY1 DIRS ETC", the variable name will be _HASH_DIRS_ETC_KEY1_
	local ParamsString="$*"
	local HashName=${PREFIX}${ParamsString// /_}_
	local KeyVarName=${HashName}${Key}_
	
	# Put the value of the key in $retval
	test $DEBUG && echo eval 'retval=${'$KeyVarName'}' 1>&2
	eval 'retval=${'$KeyVarName'}'
}

#
# $retval hashKeys <HashName> [SubHashName [...] ]
#
#	Returns a list of keys of the hash HashName in the variable $retval.
#
#	Parametes:
#		HashName
#		[SubHashName [...] ]
#			A string that contains the name of the hash. 
#			If the hash is a sub hash of another hash, the "father hash" 
#			name MUST BE WRITTEN FIRST, followed by the sub-hash name.
#			See hashSet for example.
#
#	Return value:
#		A list of the keys of the hash HashName.
#		The list is returned in the variable $retval.
hashKeys()
{
	# Parse the hash name ${PREFIX}${HashName}_${SubHashName}_...
	# Example: For the parameters "DIRS ETC" the hash name will be _HASH_DIRS_ETC_
	local ParamsString="$*"
	local HashName=${PREFIX}${ParamsString// /_}_
	
	test $DEBUG && echo eval 'retval=${'$HashName'}' 1>&2
	eval 'retval=${'$HashName'}'
}

#
# hashRemove <Key> <HashName> [SubHashName [...] ]
#
#	Removes the key Key from the hash HashName
#	
#	Parameters:
#		HashName
#		[SubHashName [...] ]
#			A string that contains the name of the hash.
#			If the hash is a sub hash of another hash, the "father hash" 
#			name MUST BE WRITTEN FIRST, followed by the sub-hash name.
#			See hashSet for example.
#		Key
#			The hash key that gets the value Value.
hashRemove()
{
	local Key=$1
	shift
	
	# Parse the hash name ${PREFIX}${HashName}_${SubHashName}_...
	# Example: For the parameters "DIRS ETC" the hash name will be _HASH_DIRS_ETC_
	local ParamsString="$*"
	local HashName=${PREFIX}${ParamsString// /_}_
	local KeyVarName=${HashName}${Key}_

	# unset the key variable
	eval "unset ${KeyVarName}"

	# Remove the key from the hash	
	eval $HashName'=${'$HashName'//' $Key '/}'
}

#
# hashDelete <HashName> [SubHashName [...] ]
#
#	Deletes the hash HashName [ SubHashName [...]]
#	
#	Parameters:
#		HashName
#		[SubHashName [...] ]
#			A string that contains the name of the hash.
#			If the hash is a sub hash of another hash, the "father hash"
#			name MUST BE WRITTEN FIRST, followed by the sub-hash name.
#			See "hashSet" for example.
hashDelete()
{
	# Parse the hash name ${PREFIX}${HashName}_${SubHashName}_...
	# Example: For the parameters "DIRS ETC" the hash name will be _HASH_DIRS_ETC_
	local ParamsString="$*"
	local HashName=${PREFIX}${ParamsString// /_}_

	# unset the hash variable
	unset `eval '${'$HashName'}'`
}
