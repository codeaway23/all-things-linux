#!/bin/sh

## minimal sofotware installation for a functional gnome GUI
sudo pacman -Syu --noconfirm linux-firmware xorg-server \
                             gdm gnome-shell gnome-terminal mutter \
                             network-manager-applet gnome-keyring \
                             gnome-backgrounds gnome-control-center \
                             gnome-tweaks \
                             gnome-shell-extensions \
                             xdg-user-dirs-gtk \
                             ntfs-3g \
                             eog totem evince file-roller nemo \
                             curl wget jq \
                             git

## enable gdm
sudo systemctl enable gdm

## generate the arch manual database
sudo pacman -S --noconfirm man-db man-pages && mandb

## handling home directory creation all users present including this one.
sudo mkhomedir_helper $USER
LC_ALL=C xdg-user-dirs-update --force

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
yay -S --noconfirm brave-bin \
                   gnome-browser-connector 

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
yay -S --noconfirm powerline-fonts-git ttf-font-awesome ttf-jetbrains-mono \
                   ttf-fira-code ttf-iosevka ttf-monoid otf-hasklig \
                   ttf-ms-fonts noto-fonts-emoji

0>/dev/null sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/themes/powerlevel10k
sed -i 's/^ZSH_THEME=\"robbyrussell\"*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' $HOME/.zshrc
sed -i 's/^plugins=(git)*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' $HOME/.zshrc
sed -i 's/.*ENABLE_CORRECTION=\"true\"*/ENABLE_CORRECTION=\"true\"/g' $HOME/.zshrc
chsh -s $(which zsh)

sudo pacman -S --noconfirm neofetch
echo "neofetch" >> $HOME/.zshrc

