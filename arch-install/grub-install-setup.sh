#!/bin/sh
set -eu

if [ $# -eq 0 ]; then
	echo "No arguments supplied. Valid options: --xorg or --wayland"
	exit 1
elif [ $# -gt 1 ]; then
	echo "Only one argument allowed. Valid options: --xorg or --wayland"
	exit 1
elif ! { [ "$1" = "--xorg" ] || [ "$1" = "--wayland" ]; }; then
	echo "Invalid argument. Valid options: --xorg or --wayland"
	exit 1
fi

## nvidia_drm.modeset=1 is the default since driver 560, but setting it
## explicitly is harmless and keeps the behaviour pinned. nvidia_drm.fbdev=1
## gives a proper framebuffer console on nvidia.
CMDLINE="cryptdevice=\/dev\/nvme0n1p3:vg00:allow-discards loglevel=3 quiet nvidia_drm.modeset=1 nvidia_drm.fbdev=1"
CRYPTDEVICE_SETTINGS="GRUB_CMDLINE_LINUX_DEFAULT=\"$CMDLINE\""

pacman -S grub dosfstools efibootmgr os-prober mtools

## The EFI partition is mounted at /boot/EFI by lvm-luks-partition.sh. Mount it
## here too if you are re-running this script on its own.
mountpoint -q /boot/EFI || { mkdir -p /boot/EFI; mount /dev/nvme0n1p1 /boot/EFI; }

grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=grub_uefi --recheck

mkdir -p /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/$CRYPTDEVICE_SETTINGS/g" /etc/default/grub

## /boot lives on its own unencrypted partition here, so GRUB itself never has
## to open the LUKS container. GRUB_ENABLE_CRYPTODISK is only needed when /boot
## is inside the encrypted volume -- leave it off.
sed -i 's/^GRUB_ENABLE_CRYPTODISK=y/#GRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub

## Since GRUB 2.06 os-prober is disabled by default; installing the package is
## not enough, this switch has to be flipped or other OSes never show up.
if grep -q "^#\?GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
	sed -i 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
else
	echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
fi

grub-mkconfig -o /boot/grub/grub.cfg
