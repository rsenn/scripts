# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NL="
"
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
# This bash library provides a set of locking tools.
# The locking is done by creating a directory named `.lock'.
# After the master-lock named `.lock' is set, a process can
# create its .lock.$$ file, and remove the master-lock.
# Each non-safe action requires a master-lock.
# Locking, unlocking, cleaning leftover locks and cleaning
# left over spin-files are non-safe action and require
# a master lock.
# Creating or removing my own spin-file and creating a
# directory that should be locked are the only actions
# done on the directory, that are considered safe.

#EXPORT=dirInitLock dirTryLock dirLock dirUnlock dirDestroyLock
#REQUIRE=

prefix=/usr
__locks_LOCKS_DIR=/var/lock/dirlocks
__locks_DEFAULT_SLEEP_TIME=0.01

__locks_ERR_DIR_IS_LOCKED=1
__locks_ERR_NO_SPIN_FILE=2
__locks_ERR_COULD_NOT_RESOLVE_DIR=3

#__locks_DEBUG_MODE=1

#############################################################
######################   FUNCTIONS   ########################
#############################################################

#
# findEffectiveDirname <DirName>
#	Finds the full path that we should lock, i.e. the effective
#	dirname we should work on.
#	This function does not change files (and therefore does not lock anything).
#	Parameters:
#		DirName -	The name of the directory we wish to lock. You can choose
#					any name if you want to
__locks_findEffectiveDirname()
{
	local DIR_NAME=$1

	# Check if it a file/dir exists
	if [ -e "$DIR_NAME" ] ; then 
		if [[ -d "$DIR_NAME" ]] ; then
			retval=$(cd "$DIR_NAME" > /dev/null 2>&1 && pwd) || \
					return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
		else
			# Get the perent directory for $DIR_NAME (full path)
			retval=$(cd $(dirname "$DIR_NAME") > /dev/null 2>&1 && pwd) || \
					return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
			# Add the basename of $DIR_NAME
			retval=$(ls -d $retval/$(basename "$DIR_NAME") 2>/dev/null) || \
					return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
		fi
		return 0
	else
		# It does not exist:
		#    Expand `\'
		#    Check that it does not contain `..' - it can be very dangerous
		while echo "$DIR_NAME" |grep -q '\\'; do DIR_NAME=$(echo "$DIR_NAME" | xargs echo); done
		echo "$DIR_NAME" | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -q '\.\.' && return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
		retval="$DIR_NAME" && return 0
	fi

	# If we got here something's wrong
	return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
}

#
# dirInitLock <DirName> [Spin]
#	Initializes a lock for a DirName object, for current process
#	
#	Parameters:
#		DirName - 	The name of the directory we wish to lock. You can choose
#					any name if you want to - i.e It does not have to be a real dir
#		Spin	-	Spin period - we'll retry to acquire lock each Spin seconds.
#					Spin may (and generally should) be less then 1. 
#					Default Spin is 0.01 seconds.
#	Return value:
#		0 - The lock was initialized and is ready for use
#		non-zero - The lock was not initialized
#
dirInitLock()
{
	local DIR_NAME=$1
	local SPIN=${2:-${__locks_DEFAULT_SLEEP_TIME}}
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval

	__locks_setMasterLock "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME"

	__locks_spinCleanup "$DIR_NAME"

	# Creating our spin-files - safe action
	echo $SPIN > "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/$$.spin"
	status=$?

	# Free the master lock
	rmdir "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock"
	
	# Return the return value of the spin-file creation command
	return $status
}

#
# dirTryLock <DirName>
#	Tries to set a lock on a directory. If lock is 
#	already set - returns immediately with error.
#
#	Parameters:
#	DirName - The name of the directory we wish to lock.
#	
#	The function exits with:
#		0 - The directory was successfully locked
#		1 - Lock was already set
#		2 - The lock object is not initialized
#
dirTryLock()
{
	local DIR_NAME=$1
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval
	
	# Check if the directory-lock is initialized
	[[ -e "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/$$.spin" ]] || return ${__locks_ERR_NO_SPIN_FILE}
	
	__locks_setMasterLock "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME"
	
	__locks_deadlockCleanup "$DIR_NAME"

	# Check if there is a lock on the directory
	if ls -d "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME"/.lock.* > /dev/null 2>&1 ; then
		# Remove the master-lock
		rmdir "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock"
		
		return ${__locks_ERR_DIR_IS_LOCKED}
	fi

	# Create a lock file for this proccess
	(umask 0 && touch "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock.$$")

	# Remove the master-lock
	rmdir "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock"
	
	# If we got here, everything worked just file.
	return 0
}

#
# dirLock <DirName>
#	Sets a lock on a directory.
#
#	Parameters:
#		DirName - The name of the directory we wish to lock.
#
#	The function exits with:
#		0 - The directory was successfully locked
#		2 - The lock object was not initialized
#
dirLock()
{
	local DIR_NAME=$1
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval
	
	#  Loop trying to lock the directory
	while true ; do
		dirTryLock "$DIR_NAME"
		local status=$?

		# If the result of the TryLock is other than an error that says that the directory is locked, return it
		[[ $status != ${__locks_ERR_DIR_IS_LOCKED} ]] && return $status

		# The return value was the __locks_ERR_DIR_IS_LOCKED error. Sleep and try again.
		sleep $(cat "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/$$.spin" 2> /dev/null) > /dev/null 2>&1 || sleep ${__locks_DEFAULT_SLEEP_TIME}
	done
}

#
# dirUnlock <DirName>
#	Free a directory from its lock.
#
#	Parameters:
#		DirName - The name of the directory we wish to unlock.
#
#	The function exits with:
#		0 - The directory was successfully unlocked
#		non-zero - Unlocking failed
#
dirUnlock()
{
	local DIR_NAME=$1
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval
	
	# Check if the directory-lock is initialized
	[[ -e "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/$$.spin" ]] || return ${__locks_ERR_NO_SPIN_FILE}
	
	__locks_setMasterLock "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME"

	__locks_deadlockCleanup "$DIR_NAME"

	# Remove my lock file
	rm -f "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock.$$" > /dev/null 2>&1

	# Remove the master lock
	rmdir "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock" > /dev/null 2>&1

	ls -la "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/".lock.* > /dev/null 2>&1 && return ${__locks_ERR_DIR_IS_LOCKED}
	
	return 0
}

#
# dirDestroyLock  <DirName>
#	Destroys the lock object. After this action the process will no longer be able to use the lock object.
#	To use the object after this action is done, one must initialize the lock, using dirInitLock.
#
#	Parameters:
#		DirName - The name of the directory that we with to destroy its lock.
#
#	The function exits with:
#		0	The action finished successfully.
#		1	The action failed. The directory is locked by your own process. Unlock it first.
#		2	The action failed. Your process did not initialize the lock.
#		3	The directory path could not be resolved.
#
dirDestroyLock()
{
	local DIR_NAME=$1
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval
	
	# Make sure that the directory is not locked
	dirTryLock "$DIR_NAME"
	if [[ "$?" == "${__locks_ERR_DIR_IS_LOCKED}" ]] ; then
		# Check if the directory is locked by this proccess
		if [[ -e "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/.lock.$$" ]] ; then
			# We can't destroy our lock while it is locked!!!
			return ${__locks_ERR_DIR_IS_LOCKED}
		fi
		
		# The directory is locked by someone else. We remove our spin file,
		# and do not touch anything else.
		rm -f "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/$$.spin"
		return 0
	fi
	dirUnlock "$DIR_NAME"

	__locks_setMasterLock "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME"

	# Remove my spoin file
	rm -f "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/$$.spin"
	# Clean the locks directories tree of this lock, as possible
	# The first thing we clean is the master-lock.
	pushd "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME" > /dev/null
	local curr_subdir=".lock"
	while rmdir "$curr_subdir" 2>/dev/null ; do
		curr_subdir=$PWD
		[[ "$curr_subdir" == ${__locks_LOCKS_DIR} ]] && break

		cd ..

		__locks_spinCleanup "$PWD"
		__locks_deadlockCleanup "$PWD"

	done
	popd > /dev/null

	return 0
}

#
# spinCleanup <DirName>
#	Cleans all unneeded spinfiles from DirName.
#	This function removes spin-files. 
#	This function does not lock the directory, even when removing
#	the files (non-safe action). That is because it is an internal
#	function that is to be used only by this library.
#	When maintaining this file notice that this is a function that
#	does not protect you from doing nasty stuff.
#	
#	If this function will be used without locking first, it can
#	cause problems. This is an internal function, so nothing like
#	that should never happened. If it does, sorry, we do not supply
#	`Stupid user protection'.
#	
#	Parameters:
#		DirName - The name of the directory we wish to clean from spinfiles.
#
#	The function exits with:
#		0 - The directory was successfully unlocked
#		non-zero - Unlocking failed
#
__locks_spinCleanup()
{
	local DIR_NAME=$1
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval
	
	# Clean dead processes spin files
	local spinfile
	for spinfile in $(ls "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME"/*.spin 2> /dev/null) ; do
		local pid=${spinfile%.spin}
		pid=${pid##*/}
		ps -ef | awk '{print $2}' | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -q "^$pid$" || rm -f $spinfile
	done
}

#
# deadlockCleanup <DirName>
#	Cleans all locks that belong to dead processes.
#	This function removes lock-files. 
#	This function does not lock the directory, even when removing
#	the files (non-safe action). That is because it is an internal
#	function that is to be used only by this library.
#	When maintaining this file notice that this is a function that
#	does not protect you from doing nasty stuff.
#	
#	If this function will be used without locking first, it can
#	cause problems. This is an internal function, so nothing like
#	that should never happened. If it does, sorry, we do not supply
#	`Stupid user protection'.
#	
#	Parameters:
#		DirName - The name of the directory we wish to clean from deadlocks.
#
#	The function exits with:
#		0 - The directory was successfully unlocked
#		non-zero - Unlocking failed
#
__locks_deadlockCleanup()
{
	local DIR_NAME=$1
	
	# Resolve effective directory name
	__locks_findEffectiveDirname "$DIR_NAME" || return ${__locks_ERR_COULD_NOT_RESOLVE_DIR}
	local EFFECTIVE_DIRNAME=$retval
	
	# Clean dead proccesses spin files
	local lockfile
	for lockfile in $(ls "${__locks_LOCKS_DIR}/$EFFECTIVE_DIRNAME/".lock.* 2> /dev/null) ; do
		local pid=${lockfile##*/.lock.}
		if ! ps -ef | awk '{print $2}' | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -q "^$pid$"  ; then
			rm -rf "$lockfile"
		fi
	done
}

# setMasterLock <DirFullPath>
#	Sets a master lock on a directory.
#	It tries to set it for 5 seconds.
#	If the master lock is set after those 5 seconds,
#	the function will sleep random amount of time (up to 1 second)
#	and will try again by calling itself recursively.
#
#	Notice that after calling this function the object will stay locked till
#	this lock is removed. This lock is not cleared by the deadlock cleanup
#	function. Therefore, if the master-lock not removed and the process exits
#	you can kiss your object good-bye. You will need to violently remove the lock.
#
#	There is no removeMasterLock function. To remove the lock you simply rmdir.
#	This lock is made to prevent two processes from setting process-specific lock
#	at the same time. Therefore, one should simply delete the directory once done
#	setting (or removing) process-specific lock.
#
#	Parameters:
#		DirFullPath - The full path of the object directory.
#
#	Return value:
#		This function returns only after setting the lock. If it returned the
#		directory was successfully locked.
#
__locks_setMasterLock()
{
	local DIR_FULL_PATH=$1

	local tries=0
	while [[ $tries -lt 50 ]] ; do
		# Creating the directory to lock
		mkdir -p "$DIR_FULL_PATH"
		# Try to set the master lock
		mkdir "$DIR_FULL_PATH/.lock" >/dev/null 2>&1 && return
		sleep 0.1
		let "tries++"
	done

	if [[ $tries -eq 50 ]] ; then
		rmdir "$DIR_FULL_PATH/.lock"
		sleep $(echo "" | awk '{srand(); print rand()}')
		__locks_setMasterLock "$DIR_FULL_PATH"
	fi
}

