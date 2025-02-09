#!/bin/sh

packagesNeeded=(sudo rsync e2fsprogs)
if [ -x "$(command -v apk)" ];
then
	sudo apk add --no-cache "${packagesNeeded[@]}"
elif [ -x "$(command -v apt-get)" ];
then
	sudo apt-get install "${packagesNeeded[@]}"
elif [ -x "$(command -v dnf)" ];
then
	sudo dnf install "${packagesNeeded[@]}"
elif [ -x "$(command -v zypper)" ];
then
	sudo zypper install "${packagesNeeded[@]}"
elif [ -x "$(command -v pacman)" ];
then
	sudo pacman -Syc "${packagesNeeded[@]}"
elif [ -x "$(command -v yum)" ];
then
	sudo yum install -y "${packagesNeeded[@]}"
else
	echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: "${packagesNeeded[@]}"">&2;
fi

sudo mkfs.ext4 /dev/sdc
## Mount Clone Filesystem
sudo mkdir /mnt/clone
sudo mount /dev/sdc /mnt/clone
## Clone FileSystem with Rsync
sudo rsync -aPHAXx --delete / /mnt/clone
sudo umount /mnt/clone
