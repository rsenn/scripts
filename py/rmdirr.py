#! /usr/bin/env python
import os,sys

version='1.0'

verbose=0

def printusage():
	print('Usage: rmdirr [-v] dirs')
	print('  -v       verbose')
	print('  -h       help')
	sys.exit()
def printhelp():
	print('rmdirr v%s - Copyright (C) 2000 Matthew Mueller - GPL license'%version)
	printusage()

def rmdirr(dir):
	names=os.listdir(dir)
	nondir=0
#	if verbose:
#		print('in dir',dir)
	for i in names:
		f=os.path.join(dir,i)
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
		optlist, args = getopt.getopt(sys.argv[1:], 'vh?')
	except getopt.error:
		print("rmdirr: %s"%getopt.error)
		printusage()

	for o,a in optlist:
		if o=='-v':
			verbose=1
		elif o=='-h' or o=='-?':
			printhelp()

	if len(args) < 1:
		printhelp()

	for a in args:
		rmdirr(a)
