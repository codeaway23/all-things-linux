#!/bin/sh

## minimal sofotware installation for a functional Xfce4 GUI
sudo pacman -Syu --noconfirm linux-firmware  \
                             xfce4 \
#                             xfce4-goodies \
                             lightdm lightdm-gtk-greeter \
                             network-manager-applet \
                             xdg-user-dirs-gtk \
                             ntfs-3g \
                             curl wget jq \
                             file-roller \
                             git

## start lightdm 
sudo systemctl enable lightdm

## generate the arch manual database
sudo pacman -S --noconfirm man-db man-pages && mandb

## handling home directory creation all users present including this one.
sudo mkhomedir_helper $USER
LC_ALL=C xdg-user-dirs-update --force

# ## create a shared directory which is open to every one (for now).
# sudo chmod ugo+rwx /home/shared

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

## dev tools
DL_DIR=/home/$USER/Downloads
mkdir -p $DL_DIR
cd $DL_DIR
curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
rm $DL_DIR/*

sudo pacman -S --noconfirm neovim

#yay -S --noconfirm visual-studio-code-insiders-bin
#cat /home/shared/all-things-linux/notes/minimal-gnome/configs/vscode-insiders/extensions-list.txt | xargs -n 1 code-insiders --install-extension

## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "anujsablework@gmail.com"
git config --global init.defaultBranch main

## install spotify
sudo pacman -S --noconfirm spotify-launcher
spotify-launcher

## relogin for zsh changes to take effect.  
# logout

## following this, you'll have to maually configure the following installed services. 
# 1. spotify
# 2. brave browser
# 3. zsh, oh-my-zsh, p10k
# 4. neovim
