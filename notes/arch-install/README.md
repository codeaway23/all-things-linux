# arch installation

#### my hard disk - 1TB NVME-SSD

## method

EFI disk (partition #1) formatted as a vfat32 filesystem.
boot disk (partition #2) is formatted as an ext4 filesystem. 
arch installation (partition #3) is encypted with `cryptsetup` LUKS.
arch installation root (logical volume #1) is formatted as a btrfs filesystem.
arch installation home (logical colume #2) is formatted as an XFS filesystem.


partition table is built using `cfdisk` as follows
1. EFI filesystem - 2G
2. Linux filesystem - 2G
3. Linux LVM - 300G

following that, run the following command.
```bash
bash lvm-luks-partition.sh

```

the script above will format your drive, partition it, create physical volumes, volume groups and 
logical volumes for home and root. the btrfs file system will have several subvolumes created as 
well. finally, it will mount all of these, use pactstrap and get you arch-chroot acccess to the 
installation. it will also move this git repository into `/mnt/home/shared/` directory. 

then, run the following commands. 
```bash
arch-chroot /mnt
mkdir -p /home/shared/
cd /home/shared
pacman -Syu git
git clone https://github.com/codeaway23/all-things-linux.git
```

`cd` into the `all-things-linux/notes/arch-install` folder. 

following that, run the following command. 
```bash
bash arch-packages.sh --name <username> --xorg
```
or 
```bash
bash arch-packages.sh --name <username> --wayland
```
depending on your requirements.

this script will install the linux kernel and all the basic packages needed for a functional arch 
system. it will also set locale, set a root password and create a user of your choice in the wheel 
group. i have currently given up on user management. but it will give your wheel group sudo 
access.

following that, again depending on your requiements, run the following.
``bash
bash grub-install-setup.sh --xorg
```
or 
```bash 
bash grub-install-setup.sh --wayland
```

this will install grub related packages, install grub on your boot drive and configure it as required.
after the installation, it will exit the chroot environment. 

now. we will configure initramfs. depending on your requirements, run the following.
```bash 
bash initramfs-setup.sh --xorg
```
or 
```bash
bash initramfs-setup-.sh --wayland
```

here, exit chroot environment, re-generate the `fstab` file to include the EFI parition as follows. 
```bash
exit
genfstab -U -p /mnt > /mnt/etc/fstab
```

unmount everything and reboot.
```bash
umount -a
reboot
```

if everything went well, your arch installation is done. 

make some minor tweaks using the following script. make sure to login as root. 
```bash
bash post-installation.sh
```

and you're done. you can move on to installing a window manager and a desktop environment. it is 
advisable you DON'T login as root but as the wheel user we created earlier. 
