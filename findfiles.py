#!/usr/bin/env python

import sys, os
import optparse

#===============================================================================
# Main function.
#===============================================================================
def main():
	(options, args) = parseArgs()

	# Extract arguments
	topDir = args[0]
	fileName = args[1]

	# Go
	resultList = []
	for dirPath, dirNames, fileNames in os.walk(topDir):
		# Remove directories to skip from list
		i = 0
		while i < len(dirNames):
			if dirNames[i] in options.pruneList:
				del dirNames[i]
			else:
				i += 1

		# Once a match have been found in a directory, don't go deeper unless
		# told otherwise
		if fileName in fileNames:
			resultList.append(os.path.join(dirPath, fileName))
			if not options.deep:
				del dirNames[:]

	# Write results to stdout
	resultList.sort()
	for result in resultList:
		sys.stdout.write(result + "\n")

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	# Setup parser
	usage = "usage: %prog [options] <topdir> <filename>"
	parser = optparse.OptionParser(usage=usage)

	# Main options
	parser.add_option("--prune",
		dest="pruneList",
		action="append",
		default=[],
		metavar="DIR",
		help="Skip this directory during search. May be used multiple times.")
	parser.add_option("--deep",
		dest="deep",
		action="store_true",
		default=False,
		help="Do not stop scanning a directory if a match has been found.")

	# Parse arguments and check validity
	(options, args) = parser.parse_args()
	if len(args) < 1:
		parser.error("Missing topdir argument")
	elif len(args) < 2:
		parser.error("Missing filename argument")
	return (options, args)

#===============================================================================
# Entry point.
#===============================================================================
if __name__ == "__main__":
	main()
