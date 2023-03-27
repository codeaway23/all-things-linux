#!/bin/sh

## user name variable
USERNAME=admin

## minimal sofotware installation for a functional gnome GUI
sudo pacman -Syu --noconfirm linux-firmware xorg-server \
                             gdm gnome-shell gnome-terminal mutter \
                             network-manager-applet gnome-keyring \
                             gnome-backgrounds gnome-control-center \
                             xdg-user-dirs-gtk \
                             ntfs-3g \
                             eog totem evince file-roller nautilus \
                             git

# generate the arch manual database
sudo -v pacman -S --noconfirm man-db man-pages && mandb

## handling home directory creation all users present including this one.
sudo mkhomedir_helper $USERNAME
LC_ALL=C xdg-user-dirs-update --force

## create a shared directory which is open to every one (for now).
sudo -v chmod ugo+rwx /home/shared

## install AUR package manager 'yay'
cd /home/shared
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd /home/$USERNAME

## install brave browser
yay -Syu
yay -S brave-bin

## fix speakers and microphone
pulseaudio --start

## start bluetooth
sudo -v systemctl enable bluetooth
sudo -v systemctl start bluetooth

## arch mirrors synchronization
sudo -v pacman -S reflector
sudo -v sed -i 's/^--sort .*/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo -v sed -i 's/^--country .*/--country India/g' /etc/xdg/reflector/reflector.conf
sudo -v systemctl enable reflector.service reflector.timer
sudo -v systemctl start reflector.service reflector.timer
sudo -v systemctl start reflector.service

## work - desktop applications
yay -S slack-desktop postman-bin

## work - VPN setup
sudo -v pacman -S openfortivpn
sudo -v cp /home/shared/all-things-linux/notes/minimal-gnome/configs/openfortivpn/config /etc/openfortivpn/config

## work - dev tools
SW_DIR=/home/$USERNAME/software
DL_DIR=/home/$USERNAME/Downloads
mkdir -p $SW_DIR
mkdir -p $DL_DIR
cd $DL_DIR
curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
curl https://github.com/elastic/elasticsearch/archive/refs/tags/v8.6.2.tar.gz -o elasticsearch.tar.gz
curl https://github.com/elastic/kibana/archive/refs/tags/v8.6.2.tar.gz -o kibana.tar.gz
curl https://github.com/elastic/logstash/archive/refs/tags/v8.6.2.tar.gz -o logstash.tar.gz
tar -xvzf elasticsearch.tar.gz -C $SW_DIR
tar -xvzf kibana.tar.gz -C $SW_DIR
tar -xvzf logstash.tar.gz $SW_DIR
rm $DL_DIR/*
sudo -v pacman -S postgresql mariadb \
               docker docker-compose
yay -S visual-studio-code-insiders-bin \
       mongodb-bin

## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "sableanuj355@gmail.com"
git config --global init.defaultBranch main

## install spotify
sudo -v pacman -S spotify-launcher
spotify-launcher
