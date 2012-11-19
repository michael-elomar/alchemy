#!/usr/bin/env python

import sys, os
import subprocess
import signal
import re

#===============================================================================
# Main function.
#===============================================================================
def main():
	shouldStop = False
	p = None

	# Signal handler, notify main loop to exit and kill subprocess
	# SIGKILL is to kill whatever process that did not stop after SIGTERM
	def signalHandler(sig, frame):
		shouldStop = True
		if p != None:
			os.killpg(p.pid, signal.SIGTERM)
			os.killpg(p.pid, signal.SIGKILL)
		else:
			sys.exit(1)

	# Try to exit silently in case of interrupts...
	signal.signal(signal.SIGINT, signalHandler)
	signal.signal(signal.SIGTERM, signalHandler)

	# Make the new child leader of a new process group so we can kill all
	# its children at once
	def preExec():
		signal.signal(signal.SIGTTOU, signal.SIG_IGN)
		os.setpgid(0, 0)
		os.tcsetpgrp(0, os.getpid())

	# Only redirect stderr (redirecting stdout causes issues if a child process
	# wants to use the terminal like ncurses)
	cmdArgs = ["make"] + sys.argv[1:]
	p = subprocess.Popen(cmdArgs,
		stderr=subprocess.PIPE,
		preexec_fn=preExec,
		shell=False)

	# Read from stderr redirected in a pipe
	reError = re.compile(r"make(\[[0-9]+\])?: \*\*\* \[[^\[\]]*\] Error [0-9]+")
	while not shouldStop:
		try:
			# Empty line means EOF detected, so exit loop
			line = p.stderr.readline()
			if len(line) == 0:
				break
			sys.stderr.write(line)
			# Check for sub-make error and kill the process group
			# SIGKILL is to kill whatever process that did not stop after SIGTERM
			if reError.match(line):
				sys.stderr.write("\n\033[31mMAKE ERROR DETECTED\n\033[00m")
				os.killpg(p.pid, signal.SIGTERM)
				os.killpg(p.pid, signal.SIGKILL)
				break
		except IOError as ex:
			# Will occur when interrupted during read, shouldStop will be set
			# at True in signalHandler
			pass

	# Exit with same result as sub-process
	p.wait()
	sys.exit(p.returncode)

#===============================================================================
# Entry point.
#===============================================================================
if __name__ == "__main__":
	main()
