#!/bin/bash

################################################################################
#                                                                              #
#    Globals                                                                   #
#                                                                              #
################################################################################

# Name of this script.
scriptname=`basename -- "$0"`

# The unified patch file being used as input.
patchfile=""

# The number of smaller patch files that have been created.
filecount=0

# The current patch file target being handled.
patchtarget=""

# The current patch file being written.
outfile=""

# The delimiting string to use for splitting the file.
delim_string="diff"

# The length of the delimiting string.
delim_length=4

# splitpatch by default will abort if it tries to create a patch file that
# already exists. If opt_append is set, it will append output to an existing
# patch file instead.
opt_append=0

# splitpatch by default will abort if it tries to create a patch file that
# already exists. If opt_overwrite is set, it will overwrite existing patch
# files instead.
opt_overwrite=0

# The environment's current IFS (will be reset by read()).
previous_IFS="$IFS"

# Unset variables trigger an error.
set -u


################################################################################
#                                                                              #
#    Functions                                                                 #
#                                                                              #
################################################################################

show_usage ()
{
	local text="USAGE"
	text="$text\n"
	text="$text       splitpatch [-a] [-o] [-d string] FILE"
	text="$text\n"
	text="$text\nDESCRIPTION"
	text="$text\n       splitpatch splits a unified patch file into smaller"
	text="$text numbered patch files. Each output patch file will modify only"
	text="$text one target file."
	text="$text\n"
	text="$text\n       splitpatch will ignore leading lines that aren't part"
	text="$text of a patch file, so go ahead and feed it shell scripts with"
	text="$text embedded unified patch files."
	text="$text\n"
	text="$text\n       splitpatch outputs the name of each patch file it"
	text="$text writes along with the patch target for that patch file."
	text="$text\n"
	text="$text\nOPTIONS"
	text="$text\n       -a"
	text="$text\n          If an output patch file already exists, try to"
	text="$text append to it instead of aborting."
	text="$text\n"
	text="$text\n       -d delimiter"
	text="$text\n          Use delimiter when splitting the input file instead"
	text="$text of 'diff'."
	text="$text\n"
	text="$text\n       -o"
	text="$text\n          If an output patch file already exists, try to"
	text="$text overwrite it instead of aborting. This option will override"
	text="$text -a."
	# fmt handles line indentation better than fold.
	echo -e "$text" | fmt -w 80
}

give_up ()
{
	IFS="$previous_IFS"
	echo
	exit
}


################################################################################
#                                                                              #
#    Main program                                                              #
#                                                                              #
################################################################################

echo

# Handle splitpatch options.
while getopts ad:o option
do
	case "$option" in
		a)
			opt_append=1;;
		d)
			delim_string="$OPTARG"
			delim_length=`printf "%s" "$delim_string" | wc -m`;;
		o)
			opt_overwrite=1;;
		[?])
			echo "Invalid option: $option"
			echo
			show_usage
			give_up;;
	esac
done

shift `expr $OPTIND - 1`

if [ $# -lt 1 ]; then
	show_usage
	give_up
fi

patchfile="$1"

# Sanity checks, make sure the patch file exists and is a regular file.
if [ ! -e "$patchfile" ]; then
	echo "Does not exist: $patchfile"
	give_up
fi
if [ ! -f "$patchfile" ]; then
	echo "Not a regular text file: $patchfile"
	give_up
fi
  echo "patchfile='$patchfile'" 1>&2

# IFS is reset to prevent read() from automatically trimming leading and
# trailing whitespace. The || test bit captures the last line of files that
# don't have a trailing newline.
while IFS= read -r patchline || test -n "$patchline"
do
  patchline=${patchline//$'\n'/"\\n"}

  #echo "patchline='$patchline'" 1>&2
	if [ "`echo "$patchline" | cut -c -$delim_length`" = "$delim_string" ]; then
		# Extract $patchtarget for nicer output.
		# Really only useful in patch files.
		if [ "$delim_string" = "diff" ]; then
			# Got a new file. Extract the file name.
			patchtarget=`echo "$patchline" | cut -c 6-`
			# Remove leading "--git" if it exists.
			if [ "`echo "$patchtarget" | cut -c -5`" = "--git" ]; then
				patchtarget=`echo "$patchtarget" | cut -c 7-`
			fi
			# Filename is duplicated and delimited by a space in the diff command.
			# This is probably the wrong way to handle this but it works for now.
			patchtarget=`echo "$patchtarget" | cut -d " " -f 1`
		else
			patchtarget="$patchline"
		fi
		filecount=`expr $filecount + 1`
    outfile=`printf "%03d.%s.patch" $filecount "$(basename -- "$patchtarget")"`
		# See if outfile already exists and handle it according to the command
		# options if it does.
		if [ -e "$outfile" ]; then
			if [ $opt_overwrite -gt 0 ]; then
				echo "Overwriting $outfile ($patchtarget)..."
				truncate -s 0 $outfile
			elif [ $opt_append -gt 0 ]; then
				echo "Appending $outfile ($patchtarget)..."
			else
				echo "$outfile already exists. Aborting."
				give_up
			fi
		else
			echo "Writing $outfile ($patchtarget)..."
		fi
	fi
	if [ $filecount -gt 0 ]; then
		echo "$patchline" >> $outfile
	fi
done < "$patchfile"

echo
echo "done."
give_up
