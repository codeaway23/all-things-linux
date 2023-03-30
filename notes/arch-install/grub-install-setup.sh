#!/bin/sh

DISK_EFI=/dev/nvme0n1p1

pacman -S grub dosfstools efibootmgr os-prober mtools

mkdir /boot/EFI
mount $DISK_EFI /boot/EFI

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

CRYPTDEVICE_SETTINGS="GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=\/dev\/nvme0n1p3:vg00:allow-discards loglevel=3 quiet\""
sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/$CRYPTDEVICE_SETTINGS/g" /etc/default/grub
sed -i 's/.*GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
