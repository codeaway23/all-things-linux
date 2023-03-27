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
