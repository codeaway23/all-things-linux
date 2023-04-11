#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No arguments supplied. Valid options: --xorg or --wayland"
	exit 1
elif [ $# -gt 1 ]; then
	echo "Only one argument allowed. Valid options: --xorg or --wayland"
	exit 1
elif [ $1 != "--xorg" || $1 != "--wayland" ]; then
	echo "Invalid argument. Valid options: --xorg or --wayland"
fi



if [ $1 == "--xorg" ]; then
	CRYPTDEVICE_SETTINGS="GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=\/dev\/nvme0n1p3:vg00:allow-discards loglevel=3 quiet\""
elif [ $1 == "--wayland" ]; then
	CRYPTDEVICE_SETTINGS="GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=\/dev\/nvme0n1p3:vg00:allow-discards loglevel=3 quiet nvidia-drm.modeset=1\""
else
	echo "Wrong argument supplied. Valid options: xorg/wayland"
	exit 1
fi

DISK_EFI=/dev/nvme0n1p1

pacman -S grub dosfstools efibootmgr os-prober mtools

mkdir /boot/EFI
mount $DISK_EFI /boot/EFI

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo


sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/$CRYPTDEVICE_SETTINGS/g" /etc/default/grub
sed -i 's/.*GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


