#!/bin/bash
# diff-whitespace-only file1 file2
# diff-whitespace-only <(command...) <(command...)

if [[ $# -ne 2 ]]; then
   echo "Usage: diff-whitespace-only file1 file2"
   exit 1
fi

# Using perl to simulate "readlink -f" on mac (to resolve sym links to the temp directory)
# git apply will complain with references via sym links.
# See: https://stackoverflow.com/a/42918/411282
tempfile1=$(perl -MCwd -le 'print Cwd::abs_path(shift)' $(mktemp -t diff-ws))
tempfile2=$(perl -MCwd -le 'print Cwd::abs_path(shift)' $(mktemp -t diff-ws))
tempfile3=$(perl -MCwd -le 'print Cwd::abs_path(shift)' $(mktemp -t diff-ws))

cat "$1" > "$tempfile1"
cat "$2" > "$tempfile2"
cp "$tempfile2" "$tempfile3"


# Had trouble in git apply with -p0 (kept the "a/b") and -p1 (stripped the
# leading slash), so stripping paths manually with --directory and -p#
tempdir=$(dirname "$tempfile1")
numslashes=$(dirname "$tempfile1" | sed 's/[^\/]//g' | wc -c | tr -d " ")

# The "git apply" below will delete temp1, and overwrite temp2 with
# temp1 + the patch that has none of the whitespace diffs between the two.
# Derived from: Add only non-whitespace changes
# https://stackoverflow.com/q/3515597/411282


# Apply only if there are non-ws differences
if ! git diff --quiet -U0 -w -b --ignore-blank-lines "$tempfile1" "$tempfile2"
then
    git diff -U0 -w -b --ignore-blank-lines --no-color "$tempfile1" "$tempfile2" \
	| git apply -p"$numslashes"  --directory "$tempdir" \
	      --whitespace=nowarn  -v --unsafe-paths  --unidiff-zero --ignore-space-change - \
	      >& /dev/null
else
    # If there's no non-ws diff, still need to overwrite to file2 where it's expected.
    cp "$tempfile1" "$tempfile2"
fi

# Now diff "old + NON-whitespace diffs" with "new" to get just the
# whitespace diffs.

git diff "$tempfile2" "$tempfile3"
#diff "$tempfile2" "$tempfile3"
