#! /bin/sh

## minimal sofotware installation for a functional system
sudo pacman -S xorg xorg-init \
	       lxsession \
	       bspwm sxhkd \
	       alacritty \
	       picom \
	       nitrogen \
	       xrandr \
	       rofi \
	       lemonbar plank \
	       zsh neovim tmux


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
yay -Syu --noconfirm brave-bin 

## configs
CONFIG_DIR=/home/$USER/.config
mkdir $COnFIG_DIR
cp -r configs $CONFIG_DIR


## executables
chmod +x $CONFIG_DIR/xinit/xinitrc

## symlinking
ln -s $CONFIG_DIR/xinit/xinitrc /home/$USER/.xinitrc
