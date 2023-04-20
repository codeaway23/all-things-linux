#! bin/sh

if [ $# -eq 0 ]; then
	echo "No arguments supplied. Valid options: --xorg or --wayland"
	exit 1
elif [ $# -gt 1 ]; then
	echo "Only one argument allowed. Valid options: --xorg or --wayland"
	exit 1
elif ! { [ $1 = "--xorg" ] || [ $1 = "--wayland" ]; }; then
	echo "Invalid argument. Valid options: --xorg or --wayland"
fi

if [ $1 = "--wayland" ]; then
	MKINIT_MODULES="(nvidia nvidia_modeset nvidia_uvm nvidia_drm)"
	sed -i "s/^MODULES=(.*/$MKINIT_MODULES/g" /etc/mkinitcpio.conf
fi

MKINIT_HOOKS="HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/^HOOKS=(.*/$MKINIT_HOOKS/g" /etc/mkinitcpio.conf
mkinitcpio -p linux-lts

if [ $1 = "--wayland" ]; then
	mkdir -p /etc/pacman.d/hooks
	cp hooks/nvidia.hook /etc/pacman.d/hooks/nvidia.hook
fi
