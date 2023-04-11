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
		   rsync \
		   bluez bluez-utils \
		   alsa-utils pulseaudio pulseaudio-bluetooth \
	       ranger zsh neovim tmux


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

## configs
CONFIG_DIR=/home/$USER/.config
mkdir $CONFIG_DIR
cp -r configs $CONFIG_DIR


## executables
chmod +x $CONFIG_DIR/xinit/xinitrc

## symlinking
ln -s $CONFIG_DIR/xinit/xinitrc /home/$USER/.xinitrc
# ln -s $CONFIG_DIR/alsa/asoundrc /home/$USER/.asoundrc
