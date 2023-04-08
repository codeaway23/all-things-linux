#!/bin/sh

if [ $# -ne 3 ]; then
	echo "Wrong arguments. First argument: --name username 
	Second option: display server. Valid options: --xorg or --wayland"
	exit 1
elif [ $1 != "--name" ]; then
	echo "First argument must be --name"
	exit
elif [$3 != "--xorg" || $3 != "--wayland"]; then
	echo "Invalid argument. Valid options: --xorg or --wayland"
fi

ADMIN=$2

## for pacman signing errors use the following lines.
#pacman-key --init
#pacman-key --populate

pacman -Syu

pacman -S base-devel \
          btrfs-progs xfsprogs \
          linux-lts linux-lts-headers \
          neovim \
          openssh \
          networkmanager wpa_supplicant netctl wireless_tools dialog \
          lvm2 \
	  nvidia-lts nvidia-utils \
	  amd-ucode

if [ $3 == "--xorg" ]; then
	pacman -S xorg
elif [ $3 == "--wayland"]; then
	pacman -S wayland
fi

sed -i "s/#en_IN.*/en_IN UTF-8/g" /etc/locale.gen
locale-gen

systemctl enable sshd
systemctl enable NetworkManager

echo "------------------------------------"
echo "set password for root"
passwd

echo "------------------------------------"
echo "set password for user $ADMIN"
useradd -m -g users -G wheel $ADMIN
passwd $ADMIN

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
