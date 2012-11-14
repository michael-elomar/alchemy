#!/usr/bin/env python

import sys, os
import subprocess, threading
import signal
import re

shouldStop = False

#===============================================================================
#===============================================================================
def readerThread(p, fh, n):
	global shouldStop
	# Regex for error line to detect
	reError = re.compile(r"make(\[[0-9]+\])?: \*\*\* \[[^\[\]]*\] Error [0-9]+")
	while not shouldStop:
		# Empty line means EOF, so exit
		line = fh.readline()
		if len(line) == 0:
			return
		line = line.rstrip("\n")

		# Display line in the correct stream
		if n == 1:
			sys.stdout.write(line+"\n")
		else:
			sys.stderr.write(line+"\n")

		# Detect error in stderr
		if not shouldStop and n == 2 and reError.match(line):
			sys.stderr.write("\n\033[31mMAKE ERROR DETECTED\n\033[00m")
			# Kill the process group (so all sub-makes...)
			shouldStop = True
			os.killpg(0, signal.SIGTERM)

#===============================================================================
#===============================================================================
def signalHandler(sig, frame):
	global shouldStop
	shouldStop = True
	sys.exit(1)

#===============================================================================
# Main function.
#===============================================================================
def main():
	# Try to exit silently in case of interrupts...
	signal.signal(signal.SIGINT, signalHandler)
	signal.signal(signal.SIGTERM, signalHandler)

	# call make with given arguments
	cmdArgs = ["make"] + sys.argv[1:]
	p = subprocess.Popen(cmdArgs,
		stdout=subprocess.PIPE,
		stderr=subprocess.PIPE,
		shell=False)

	# Start thread to read stdout/stderr
	stdoutThread = threading.Thread(target=readerThread, args=(p, p.stdout, 1))
	stdoutThread.setDaemon(True)
	stdoutThread.start()
	stderrThread = threading.Thread(target=readerThread, args=(p, p.stderr, 2))
	stderrThread.setDaemon(True)
	stderrThread.start()

	# Wait everybody
	stdoutThread.join()
	stderrThread.join()
	p.wait()

	# Exit with same result as make
	sys.exit(p.returncode)

#===============================================================================
# Entry point.
#===============================================================================
if __name__ == "__main__":
	main()
