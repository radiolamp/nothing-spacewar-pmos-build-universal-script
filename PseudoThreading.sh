#!/bin/bash
# Pseudo multithreading in bash script
# This one is a sudo keepalive test, prob won't work with doas

# Change this setting to no more than 60% of your sudo timeout
sudo_system_timeout=10


MainThread()
{
	echo Waiting about 1 minutes to test sudo
	sleep 50
	echo running dmesg as sudo
	sudo -s dmesg
	echo back out of sudo and sending exit signal to other thread

	# run a sync to flush caches, wait a bit before signalling.
	sync
	sleep 1
	touch /tmp/sudopassed
	# xterm exiting prevents cleanup, give time for the signal
	while [ -f /tmp/sudopassed ]
	do
		echo signal file not removed
		sleep 5
	done
}

KeepAlive()
{
# The sleep statements in the exit logic is to give time for files to
# write and unwrite. Without, this script breaks on my system.

	while (true)
	do
		echo resetting sudo timeout
		sudo -v
		if [ -f /tmp/sudopassed ]; then
			sleep 1
			echo got exit signal, exiting...
			sudo rm /tmp/sudopassed
			sync
			# to reduce the race condition further
			if [ ! -f /tmp/sudopassed ]; then
				exit 0
			fi
			echo signal failed to drop, retrying...
		fi
		sleep $sudo_system_timeout
	done
}





# Rather than exit entirely, we run bash, then we can see the results.
#MAIN
	case $1 in
			run)
			echo $sudo_system_timeout
			sudo -v
			KeepAlive &
			MainThread
			bash
			;;
	*)
			self=$0
			xterm -e bash $self run &
			;;
	esac
