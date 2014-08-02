#!/usr/bin/env python

import sys, os, logging
import optparse
import re
import stat

#===============================================================================
#===============================================================================
class CpioHeader(object):
	def __init__(self, filePath, fileSize, mode, uid, gid):
		self.filePath = filePath
		self.fileSize = fileSize
		self.mode = mode
		self.uid = uid
		self.gid = gid
		self.major = 0
		self.minor = 0

#===============================================================================
#===============================================================================
class Cpio(object):
	def __init__(self, fdout):
		self.writeLen = 0
		self.inode = 0
		self.fdout = fdout

	def align4(self):
		for _ in range(0, (4 - self.writeLen % 4) % 4):
			self.fdout.write("\0")
			self.writeLen += 1

	def align512(self):
		for _ in range(0, (512 - self.writeLen % 512) % 512):
			self.fdout.write("\0")
			self.writeLen += 1

	def write(self, buf):
		self.fdout.write(buf)
		self.writeLen += len(buf)

	def writeHeader(self, hdr):
		buf = ("%s%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x" % (
				"070701", self.inode,
				hdr.mode, hdr.uid, hdr.gid, 1, 0,
				hdr.fileSize, 0, 0, hdr.major, hdr.minor,
				len(hdr.filePath) + 1, 0))
		self.write(buf)
		self.write(hdr.filePath + "\0")
		self.align4()
		self.inode += 1

#===============================================================================
# Main function.
#===============================================================================
def main():
	(options, args) = parseArgs()
	setupLog(options)
	initFound = False

	# Open output cpio file
	outCpioPath = args[0]
	try:
		fdout = open(outCpioPath, "wb")
	except IOError as ex:
		logging.error("Failed to open file: %s [err=%d %s]",
				outCpioPath, ex.errno, ex.strerror)
		sys.exit(1)
	cpio = Cpio(fdout)

	# Read file names on stdin
	reLine = re.compile("([^;]*);mode=([0-7]*);uid=([0-9]*);gid=([0-9]*)")
	for line in sys.stdin:
		buf = line.rstrip("\n")
		match = reLine.match(buf)
		filePath = match.group(1)
		mode = int(match.group(2), 8)
		uid = int(match.group(3))
		gid = int(match.group(4))
		if filePath == "/init" or filePath == "init":
			initFound = True

		if stat.S_IFMT(mode) == stat.S_IFREG:
			# Try to open file
			try:
				fdin = open(filePath, "rb")
			except IOError as ex:
				logging.error("Failed to open file: %s [err=%d %s]",
						filePath, ex.errno, ex.strerror)
				sys.exit(1)

			# Get file size
			fdin.seek(0, 2)
			fileSize = fdin.tell()
			fdin.seek(0, 0)

			# Write file header
			cpioHeader = CpioHeader(filePath, fileSize, mode, uid, gid)
			cpio.writeHeader(cpioHeader)

			# Write file content
			cpio.write(fdin.read(fileSize))
			cpio.align4()
			fdin.close()
		elif stat.S_IFMT(mode) == stat.S_IFDIR:
			# No data, only header
			cpioHeader = CpioHeader(filePath, 0, mode, uid, gid)
			cpio.writeHeader(cpioHeader)
		elif stat.S_IFMT(mode) == stat.S_IFLNK:
			# Data is link target
			linkTarget = os.readlink(filePath)
			cpioHeader = CpioHeader(filePath, len(linkTarget), mode, uid, gid)
			cpio.writeHeader(cpioHeader)
			cpio.write(linkTarget)
			cpio.align4()

	# Device nodes
	for devNode in options.devNodes:
		fields = devNode.split(":")
		filePath = fields[0]
		mode = int(fields[1], 8)
		uid = int(fields[2], 10)
		gid = int(fields[3], 10)
		devtype = fields[4]
		major = int(fields[5], 10)
		minor = int(fields[6], 10)
		if devtype == "b":
			mode |= stat.S_IFBLK
		else:
			mode |= stat.S_IFCHR
		# No data, only header
		cpioHeader = CpioHeader(filePath, 0, mode, uid, gid)
		cpioHeader.major = major
		cpioHeader.minor = minor
		cpio.writeHeader(cpioHeader)

	# Trailer
	cpioHeader = CpioHeader("TRAILER!!!", 0, 0, 0, 0)
	cpio.writeHeader(cpioHeader)
	cpio.align512()

	# Free resources
	fdout.close()

	if not initFound:
		logging.warning("cpio: warning: no 'init' found at the root")

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	usage = "usage: %prog [options] <cpiofile>"
	parser = optparse.OptionParser(usage = usage)

	parser.add_option("--devnode",
		dest="devNodes",
		action="append",
		default=[],
		help="add a device node (format is name:mode:uid:gid:c|b:maj:min")

	parser.add_option("-q",
		dest="quiet",
		action="store_true",
		default=False,
		help="be quiet")
	parser.add_option("-v",
		dest="verbose",
		action="count",
		default=0,
		help="verbose output (more verbose if specified twice)")

	(options, args) = parser.parse_args()
	if len(args) != 1:
		parser.error("Missing <cpiofile>")
	return (options, args)

#===============================================================================
# Setup logging system.
#===============================================================================
def setupLog(options):
	logging.basicConfig(
		level=logging.WARNING,
		format="[%(levelname)s] %(message)s",
		stream=sys.stderr)
	logging.addLevelName(logging.CRITICAL, "C")
	logging.addLevelName(logging.ERROR, "E")
	logging.addLevelName(logging.WARNING, "W")
	logging.addLevelName(logging.INFO, "I")
	logging.addLevelName(logging.DEBUG, "D")

	# setup log level
	if options.quiet == True:
		logging.getLogger().setLevel(logging.CRITICAL)
	elif options.verbose >= 2:
		logging.getLogger().setLevel(logging.DEBUG)
	elif options.verbose >= 1:
		logging.getLogger().setLevel(logging.INFO)

#===============================================================================
# Entry point.
#===============================================================================
if __name__ == "__main__":
	main()
