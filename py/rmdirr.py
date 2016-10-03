#! /usr/bin/env python
import os,sys
import fnmatch, re

version='1.0'

verbose=0
excludefn = []

def printusage():
	print('Usage: rmdirr [-v] [-x PATTERN] dirs')
	print('  -v           verbose')
	print('  -x PATTERN   exclude')
	print('  -h           help')
	sys.exit()
def printhelp():
	print('rmdirr v%s - Copyright (C) 2000 Matthew Mueller - GPL license'%version)
	printusage()

def excludematch(fn):
	if len(excludefn):
		for ptrn in excludefn:
			if fnmatch.fnmatch(fn, ptrn):
				return 1
	return 0

def rmdirr(dir):
	names=os.listdir(dir)
	nondir=0

	for i in names:
		f=os.path.join(dir,i)
		if excludematch(f):
			if verbose:
				print('skipping "%s"'%f)
			continue
		if os.path.isdir(f):
			nondir=nondir+rmdirr(f)
		else:
			nondir=nondir+1
	if nondir==0:
		if verbose:
			print('removing empty dir',dir)
		os.rmdir(dir)
#	else:
#		if verbose:
#			print('dir',dir,'had',nondir,'nondirs in it')
	return nondir

if __name__ == "__main__":
	import getopt
	try:
		optlist, args = getopt.getopt(sys.argv[1:], 'vx:h', ["verbose", "exclude=", "help"])
	except getopt.error:
		print("rmdirr: %s"%getopt.error)
		printusage()
	for o,a in optlist:	
		if o in("-v", "--verbose"):
			verbose=1
		elif o in("-x", "--exclude"):
			excludefn += [a]
		elif o in("-h", "--help"):
			printhelp()

	if verbose:
		print('excludefn: "%s"'%'", "'.join(excludefn))

	if len(args) < 1:
		printhelp()

    

	for a in args:
		rmdirr(a)
