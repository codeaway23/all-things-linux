  GNU nano 7.2                                 arch-install.sh                                 Modified  
#!/bin/sh

pacman-key --init
pacman-key --populate

pacman -Syu

pacman -S base base-devel btrfs-progs \
          linux-lts linux-lts-headers \
          nano neovim \
          openssh \
          networkmanager wpa_supplicant netctl wireless_tools dialog \
          lvm2 


sudo -v sed -i 's/^--sort .*/--sort rate/g' /etc/mkinitcpio.conf

systemctl enable sshd
systemctl enable NetworkManager

