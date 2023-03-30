#!/bin/sh

DISK_EFI=/dev/nvme0n1p1
DISK_BOOT=/dev/nvme0n1p2
DISK_ARCH=/dev/nvme0n1p3

cryptseetup luksFormat $DISK_ARCH
cryptsetup luksOpen $DISK_ARCH arch

pvcreate --dataalignment 1M /dev/mapper/arch
vgcreate vg00 /dev/mapper/arch
lvcreate -L 50G -n lv-root vg00
lvcreate -l 100%FREE -n lv-home vg00

modprobe dm_mod
vgscan
vgchange -ay

mkfs.fat -F 32 $DISK_EFI
mkfs.ext4 $DISK_BOOT
mkfs.btrfs /dev/vg00/lv-root
mkfs.xfs /dev/vg00/lv-home

mount /dev/vg00/lv-root /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@root
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@log
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@tmp

umount /mnt

mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ /dev/vg00/lv-root /mnt

mkdir -p /mnt/{home,root,srv,var/log,var/cache,tmp}

mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home /dev/vg00/lv-root /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@root /dev/vg00/lv-root /mnt/root
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@srv /dev/vg00/lv-root /mnt/srv
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@log /dev/vg00/lv-root /mnt/var/log
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@cache /dev/vg00/lv-root /mnt/var/cache
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@tmp /dev/vg00/lv-root /mnt/tmp

mount /dev/vg00/lv-home /mnt/home

mkdir -p /mnt/boot
mount $DISK_BOOT /mnt/boot

genfstab -U -p /mnt > /etc/fstab

pacstrap -i /mnt base

cd ~
mkdir -p /mnt/home/shared
cp -r all-things-linux /mnt/home/shared
arch-chroot /mnt
cd /home/shared/all-things-linux/notes/arch-install