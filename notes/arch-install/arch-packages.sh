#!/bin/sh

ADMIN=admin
NEW_USER=anuj

pacman-key --init
pacman-key --populate

pacman -Syu

pacman -S base-devel \
          btrfs-progs \
          linux-lts linux-lts-headers \
          nano neovim \
          openssh \
          networkmanager wpa_supplicant netctl wireless_tools dialog \
          lvm2 

MKINIT_HOOKS="HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/^HOOKS=(.*/$MKINIT_HOOKS/g" /etc/mkinitcpio.conf
mkinitcpio -p linux-lts

sed -i "s/#en_IN.UTF-8/en.IN.UTF-8/g" /etc/locale.gen
locale-gen

systemctl enable sshd
systemctl enable NetworkManager

passwd

useradd -m -g users -G wheel $ADMIN
passwd $ADMIN

useradd -m -g users $NEW_USER
passwd $NEW_USER

