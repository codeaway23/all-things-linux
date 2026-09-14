#!/bin/sh
set -eu

if [ $# -ne 3 ]; then
	echo "Wrong arguments. First argument: --name username 
	Second option: display server. Valid options: --xorg or --wayland"
	exit 1
elif [ "$1" != "--name" ]; then
	echo "First argument must be --name"
	exit 1
elif ! { [ "$3" = "--xorg" ] || [ "$3" = "--wayland" ]; }; then
	echo "Invalid argument. Valid options: --xorg or --wayland"
	exit 1
fi

ADMIN=$2

## for pacman signing errors use the following lines.
#pacman-key --init
#pacman-key --populate archlinux

pacman -Syu

pacman -S base-devel \
          btrfs-progs xfsprogs \
          linux-lts linux-lts-headers linux-firmware \
          neovim \
          openssh \
          networkmanager wpa_supplicant iw \
          lvm2 \
          sudo

if [ "$3" = "--xorg" ]; then
	pacman -S xorg-server xorg-xinit xorg-xrandr
elif [ "$3" = "--wayland" ]; then
	pacman -S wayland xorg-xwayland
fi

## Legion 5 Pro 16ACH6H: Ryzen 7 5800H (Cezanne iGPU) + RTX 30-series dGPU.
## nvidia-open is what NVIDIA and Arch now recommend for Turing and newer, and
## Ampere qualifies. For Maxwell/Pascal and older, swap this for `nvidia-lts`.
pacman -S nvidia-open-lts nvidia-utils nvidia-prime \
          amd-ucode

## Hybrid graphics: the AMD iGPU drives the internal panel in hybrid mode, so it
## needs its own userspace stack. Without this the iGPU falls back to software
## rendering and the laptop display is slow even though the dGPU is installed.
## `prime-run <app>` then offloads a single app to the nvidia card.
pacman -S mesa vulkan-radeon vulkan-icd-loader xf86-video-amdgpu

## Battery conservation mode / fan curves on the Legion are exposed through
## acpi_call. Pair with the lenovolegionlinux-dkms-git AUR module if you want
## the full fan-curve and power-mode control.
pacman -S acpi_call-dkms

## locale
sed -i "s/^#\(en_IN.*\)/\1/" /etc/locale.gen
sed -i "s/^#\(en_US\.UTF-8 UTF-8\)/\1/" /etc/locale.gen
grep -q "^en_" /etc/locale.gen || echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
## locale-gen alone does not set the system locale; /etc/locale.conf does.
echo "LANG=en_IN.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

## clock
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

systemctl enable sshd
systemctl enable NetworkManager

echo "------------------------------------"
echo "set password for root"
passwd

echo "------------------------------------"
echo "set password for user $ADMIN"
useradd -m -g users -G wheel "$ADMIN"
passwd "$ADMIN"

## drop-in instead of appending to /etc/sudoers, and validate before it takes
## effect -- a malformed /etc/sudoers locks you out of sudo entirely.
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
chmod 0440 /etc/sudoers.d/10-wheel
visudo -c
