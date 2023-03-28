# arch installation

hard disk - 1TB NVME-SSD

EFI disk (partition #1) formatted as a vfat32 filesystem. 
boot disk (partition #2) is formatted as an ext4 filesystem. 
arch installation (partition #3) is encypted with `cryptsetup` LUKS.
arch installation root (logical volume #1) is formatted as a btrfs filesystem.
arch installation home (logical colume #2) is formatted as an XFS filesystem.

partition table is built using cfdisk as follows
1. EFI filesystem - 2G
2. Linux filesystem - 2G
3. Linux LVM - 300G

following that, run the following command.
```bash
bash lvm-luks-partition.sh
```

the script above will format your drive, partition it, create physical volumes, volume groups and 
logical volumes for home and root. the btrfs file system will have several subvolumes created as 
well. 

finally, it will mount all of these, use pactstrap and get you arch-chroot acccess to the 
installation. 

following that, run the following command. 
```bash
bash arch-packages.sh
```

this script will install the linux kernel and all the basic packages needed for a functional arch 
system. it will also set locale, set a root password and create a user in the wheel 
group called admin. 

following this, this part has to be done manually. 
run the following command.
```bash
EDITOR=nano visudo
```

it'll open a file in the nano text editor. 
find and uncomment the line `%wheel ALL=(ALL) ALL`.
save the file and exit. 

following that, run the following command.
```bash
bash grub-install-setup.sh
```

this will install grub related packages, install grub on your boot drive and configure it as required.
after the installation, it will exit the chroot environment. 

here, re-generate the `fstab` file to include the EFI parition as follows.
```bash
genfstab -U -p /mnt > /mnt/etc/fstab
```

unmount everything and reboot.
```bash
umount -a
reboot
```

if everything went well, your arch installation is done. 

make some minor tweaks using the following script. 
```bash
bash post-installation.sh
```

and you're done. you can move on to installing a window manager and a desktop environment. 
