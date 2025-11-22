#!/bin/bash
# Pseudo multithreading in bash script
# This one is a sudo keepalive test, prob won't work with doas

# Change this setting to no more than 60% of your sudo timeout
sudo_system_timeout=10


MainThread()
{

set -e
# login to make sudo request less, scatter these around hoping to quash much of them
sudo -v
# reference run from dir to overcome ~/ not working in $PATH
export SCRIPT_RAN_FROM_DIR=$PWD
export PATH="$PATH:$HOME/.local/bin"

set +e

## Clean up first, but only if they exist, presumably due to build errors, to protect from rm -rf mistakes.
echo cleaning old or failed builds if exists...
if [ -d $SCRIPT_RAN_FROM_DIR/pmbootstrap ]; then
  echo -e "n\nn\ny\n" | pmbootstrap zap
  sync
  rm -rf pmbootstrap; fi
if [ -d $HOME/.local/var/pmbootstrap ]; then
  sudo rm -rf $HOME/.local/var/pmbootstrap
fi
if [ -d $SCRIPT_RAN_FROM_DIR/out ]; then
  rm -rf out;
fi
sync
echo cleaned.

set -e

find . -type f -name "*.conf" -exec sh -c 'cp "$1" "${1%.conf}.cfg"' _ {} \;

# Replace placeholders in .cfg files, checked and this really is needed during my line by line debug
find . -type f -name "*.cfg" -exec sed -i "s|HOME|$(echo $HOME)|;s|NPROC|$(nproc)|" {} +

# Setup environment
export KERNEL_BRANCH=danila/spacewar-testing

# Install pmbootstrap from Git
git clone https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git --depth 1
mkdir -p $HOME/.local/bin

if [ -f $HOME/.local/bin/pmbootstrap ]; then rm $HOME/.local/bin/pmbootstrap; fi
ln -s "$PWD/pmbootstrap/pmbootstrap.py" $HOME/.local/bin/pmbootstrap
pmbootstrap --version
sync
sudo -v

# Init, bruv
echo -e '\n\n' | pmbootstrap init || true
cd $HOME/.local/var/pmbootstrap/cache_git/pmaports

# Kernel branch setup
export DEFAULT_BRANCH=danila/spacewar-mr
git remote add sc7280 https://github.com/mainlining/pmaports.git
git fetch sc7280 $DEFAULT_BRANCH
git reset --hard sc7280/$DEFAULT_BRANCH
export DEFAULT_BRANCH=danila/spacewar-testing
echo "Default branch is $DEFAULT_BRANCH"
git clone https://github.com/mainlining/linux.git --single-branch --branch $KERNEL_BRANCH --depth 1
sync
sudo -v
# Copy config to pmbootstrap
cp $SCRIPT_RAN_FROM_DIR/nothing-spacewar-phosh.cfg $HOME/.config/pmbootstrap_v3.cfg

# Compile kernel image
cd linux
shopt -s expand_aliases
source $SCRIPT_RAN_FROM_DIR/pmbootstrap/helpers/envkernel.sh
make defconfig sc7280.config
make -j$(nproc)
pmbootstrap build --envkernel linux-postmarketos-qcom-sc7280
sync
sudo -v

# Build pmos images, failed here, but doesn't look like script issue
echo building images
cp $SCRIPT_RAN_FROM_DIR/nothing-spacewar-phosh.cfg $HOME/.config/pmbootstrap.cfg
sync
pmbootstrap -t 6000 install --password 1114
sync
sudo -v

# Export build images to outdir
echo exporting images
pmbootstrap export
mkdir $SCRIPT_RAN_FROM_DIR/out

cp /tmp/postmarketOS-export/boot.img $SCRIPT_RAN_FROM_DIR/out/boot-nothing-spacewar.img
cp /tmp/postmarketOS-export/nothing-spacewar.img $SCRIPT_RAN_FROM_DIR/out/rootfs-nothing-spacewar.img
tar -c -I 'xz -9 -T0' -f $SCRIPT_RAN_FROM_DIR/out/Spacewar_pmos.tar.xz $SCRIPT_RAN_FROM_DIR/out/rootfs-nothing-spacewar.img $SCRIPT_RAN_FROM_DIR/out/boot-nothing-spacewar.img
cp $SCRIPT_RAN_FROM_DIR/flashpmos.sh $SCRIPT_RAN_FROM_DIR/out/flashpmos.sh 
echo -e "n\nn\ny\n" | pmbootstrap zap
# Just to tidy up the folder, gets replaced anyway
rm $SCRIPT_RAN_FROM_DIR/*.cfg



	# everything after here is exit safety code.
	set +e
	echo Finished, shutting down script services...
	sync
	sleep 1
	touch /tmp/PmosBuildDone.sudo
	# xterm exiting prevents cleanup, give time for the signal
	while [ -f /tmp/PmosBuildDone.sudo ]
	do
		sleep 5
	done
}

KeepAlive()
{
# The sleep statements in the exit logic is to give time for files to
# write and unwrite. Without, this script breaks on my system.

	while (true)
	do
		sudo -v
		if [ -f /tmp/PmosBuildDone.sudo ]; then
			sleep 1
			echo got exit signal, exiting...
			sudo rm /tmp/PmosBuildDone.sudo
			sync
			# to reduce the race condition further
			if [ ! -f /tmp/PmosBuildDone.sudo ]; then
				echo exited sudo watchdog
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
			sudo -v
			KeepAlive &
			MainThread
			# bash
			;;
	*)
			self=$0
			$self run
			# Remove above line and uncoment this if you have xterm installed 
			# xterm -e bash $self run &
			;;
	esac
