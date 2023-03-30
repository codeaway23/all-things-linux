#!/bin/sh

## minimal sofotware installation for a functional gnome GUI
sudo pacman -Syu --noconfirm linux-firmware xorg-server \
                             gdm gnome-shell gnome-terminal mutter \
                             network-manager-applet gnome-keyring \
                             gnome-backgrounds gnome-control-center \
                             xdg-user-dirs-gtk \
                             ntfs-3g \
                             eog totem evince file-roller nautilus \
                             curl wget jq \
                             git

## generate the arch manual database
sudo pacman -S --noconfirm man-db man-pages && mandb

## handling home directory creation all users present including this one.
sudo mkhomedir_helper $USER
LC_ALL=C xdg-user-dirs-update --force

## create a shared directory which is open to every one (for now).
sudo chmod ugo+rwx /home/shared

## where all user software lies
SW_DIR=/home/$USER/software
mkdir -p $SW_DIR

## install AUR package manager 'yay'
cd $SW_DIR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd /home/$USER

## install brave browser
yay -Syu --noconfirm
yay -S --noconfirm brave-bin

## fix speakers and microphone
pulseaudio --start

## start bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

## arch mirrors synchronization
sudo pacman -S --noconfirm reflector
sudo sed -i 's/^--sort .*/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo sed -i 's/^--country .*/--country India/g' /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector.service reflector.timer
sudo systemctl start reflector.service reflector.timer
sudo systemctl start reflector.service

## shell, font and theme
sudo pacman -S --noconfirm zsh gsfonts
yay -S --noconfirm powerline-fonts-git ttf-font-awesome ttf-jetbrains-mono ttf-fira-code ttf-iosevka ttf-monoid otf-hasklig \
                   ttf-ms-fonts                  

0>/dev/null sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/themes/powerlevel10k
sed -i 's/^ZSH_THEME=\"robbyrussell\"*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' $HOME/.zshrc
sed -i 's/^plugins=(git)*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' $HOME/.zshrc
sed -i 's/.*ENABLE_CORRECTION=\"true\"*/ENABLE_CORRECTION=\"true\"/g' $HOME/.zshrc

## work - desktop applications
yay -S --noconfirm slack-desktop

## work - VPN setup
sudo pacman -S --noconfirm openfortivpn
sudo cp /home/shared/all-things-linux/notes/minimal-gnome/configs/openfortivpn/config /etc/openfortivpn/config

## work - dev tools
DL_DIR=/home/$USER/Downloads
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
sudo pacman -S --noconfirm postgresql mariadb \
                           rclone \
                           docker docker-compose
yay -S --noconfirm  postman-bin \
                    mongodb-bin

## work - vs-code-insiders - with extensions
yay -S visual-studio-code-insiders-bin
cat /home/shared/all-things-linux/notes/minimal-gnome/configs/vscode-insiders/extensions-list.txt | xargs -n 1 code-insiders --install-extension

## work - install google calendar, gmail on thunderbird
sudo paman -S --noconfirm thunderbird

## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "anujsablework@gmail.com"
git config --global init.defaultBranch main

## install spotify
sudo pacman -S --noconfirm spotify-launcher
spotify-launcher

## restart system for zsh changes to take effect. after reboot, zsh will ask you to configure p10k. 
# reboot

## following this, you'll have to maually configure the following installed services. 
# 1. spotify
# 2. thunderbird
# 3. postman
# 4. visual studio
# 5. slack
# 6. brave browser
