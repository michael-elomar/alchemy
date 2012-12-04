#!/usr/bin/env python

import sys, os
import subprocess
import signal
import time
import re

#===============================================================================
# Kill make
# p: make sub-process.
#===============================================================================
def killMake(p):
	# Interrupt top level make, then everyone in the process group,
	# then kill remaining Some time later
	time.sleep(0.2)
	os.kill(p.pid, signal.SIGINT)
	time.sleep(0.2)
	os.killpg(p.pid, signal.SIGINT)
	time.sleep(0.2)
	os.killpg(p.pid, signal.SIGKILL)

#===============================================================================
# Main function.
#===============================================================================
def main():
	p = None

	# Remember which process group was associated with terminal to restore  it
	# after we played with it
	tcpgrp = os.tcgetpgrp(0)

	# If MAKELEVEL is defined, we are in a sub-make so don't play with
	# process groups or killing
	useKillpg = (not "MAKELEVEL" in os.environ)

	# Signal handler, kill subprocess
	# SIGKILL is to kill whatever process that did not stop after SIGTERM
	def signalHandler(sig, frame):
		if p != None:
			if useKillpg:
				killMake(p)
			else:
				p.terminate()
		else:
			sys.exit(1)

	# Try to exit silently in case of interrupts...
	signal.signal(signal.SIGINT, signalHandler)
	signal.signal(signal.SIGTERM, signalHandler)

	# Make the new child leader of a new process group so we can kill all
	# its children at once
	def preExec():
		if useKillpg:
			signal.signal(signal.SIGTTOU, signal.SIG_IGN)
			os.setpgid(0, 0)
			os.tcsetpgrp(0, os.getpid())

	# Only redirect stderr (redirecting stdout causes issues if a child process
	# wants to use the terminal, like ncurses)
	# Force locale to have english messages that we will try to detect
	env = os.environ
	env["LANG"] = "C"
	cmdArgs = ["make"] + sys.argv[1:]
	p = subprocess.Popen(cmdArgs,
		stderr=subprocess.PIPE,
		preexec_fn=preExec,
		shell=False, env=env)

	# Read from stderr redirected in a pipe
	# only catch top level makefile errors (sub-make files error will eventually
	# generate a top level error)
	reError1 = re.compile(r"make: \*\*\* No rule to make target .*")
	reError2 = re.compile(r"make: \*\*\* \[[^\[\]]*\] (Error|Erreur) [0-9]+")
	errorDetected = False
	while True:
		try:
			# Empty line means EOF detected, so exit loop
			line = p.stderr.readline()
			if len(line) == 0:
				break
			if not errorDetected:
				sys.stderr.write(line)
			# Check for make error
			if reError1.match(line) or reError2.match(line):
				errorDetected = True
				if useKillpg:
					killMake(p)
				else:
					p.terminate()
		except IOError as ex:
			# Will occur when interrupted during read, an EOF will be read next
			pass

	# Only print message once at the end
	if errorDetected:
		sys.stderr.write("\n\033[31mMAKE ERROR DETECTED\n\033[00m")

	# Wait for sub-process to terminate
	p.wait()

	# Restore stuff
	signal.signal(signal.SIGTTOU, signal.SIG_IGN)
	os.tcsetpgrp(0, tcpgrp)

	# Exit with same result as sub-process
	sys.exit(p.returncode)

#===============================================================================
# Entry point.
#===============================================================================
if __name__ == "__main__":
	main()
