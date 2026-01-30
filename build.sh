#!/bin/bash

set -e
# login prompt to get a password for sudo, insecure, but I don't yet know of a safer option
echo -e "This script needs the password for sudo,"
echo -n "please type password and press enter: "
read BUILD_SUDO_PASSWORD

#reference I made as I experimented, sussed I needed to use double quotes to prevent accidental command escaping:
#echo -n "input: ";read input;echo "$input"
#Insecure way of working around sudo timeouts, but YOLO:
echo $BUILD_SUDO_PASSWORD |sudo -v -S
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
sync
mv ./conf/*.cfg ./
sync
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
echo "$BUILD_SUDO_PASSWORD\n" |sudo -v -S
#sudo -v

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
echo "$BUILD_SUDO_PASSWORD\n" |sudo -v -S
#sudo -v
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
echo "$BUILD_SUDO_PASSWORD\n" |sudo -v -S
#sudo -v

# make local dependencies including placeholder depends
PRE_DEPS_DIR=$PWD
cd $SCRIPT_RAN_FROM_DIR/makePKG
./make-manual-depends.sh
cd $SCRIPT_RAN_FROM_DIR
cd $PRE_DEPS_DIR
sync

# Build pmos images, failed here, but doesn't look like script issue
echo building images
cp $SCRIPT_RAN_FROM_DIR/nothing-spacewar-phosh.cfg $HOME/.config/pmbootstrap.cfg
sync
pmbootstrap -t 6000 install --password 1114
sync
echo "$BUILD_SUDO_PASSWORD\n" |sudo -v -S
#sudo -v

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
