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

## Early KMS for nvidia is recommended on both X11 and Wayland now -- it avoids
## the console-mode flicker during boot and is required for nvidia_drm.modeset.
MKINIT_MODULES="MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)"
sed -i "s/^MODULES=(.*/$MKINIT_MODULES/g" /etc/mkinitcpio.conf

## `microcode` (mkinitcpio >= 38) is the current way to load CPU microcode: it
## bundles amd-ucode/intel-ucode into the initramfs instead of relying on a
## separate initrd line in the bootloader. It must sit directly after autodetect.
MKINIT_HOOKS="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/^HOOKS=(.*/$MKINIT_HOOKS/g" /etc/mkinitcpio.conf

## -P builds every preset; -p <preset> is the legacy single-preset form.
mkinitcpio -P

## The hand-rolled /etc/pacman.d/hooks/nvidia.hook this script used to install is
## obsolete: the nvidia packages ship their own hook at
## /usr/share/libalpm/hooks/nvidia.hook, and mkinitcpio's built-in hooks now
## rebuild the initramfs when the nvidia kernel module changes.
