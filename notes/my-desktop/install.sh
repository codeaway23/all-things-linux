#! /bin/sh

## minimal sofotware installation for a functional system
sudo pacman -S xorg xorg-init \
	       bspwm sxhkd \
	       alacritty \
	       picom \
		   xrandr \
	       rofi \
	       polybar \ 
	       rsync \
	       bluez bluez-utils \
	       alsa-utils pulseaudio pulseaudio-bluetooth \
	       ranger zsh neovim

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
rfkill unblock bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
yay -S --noconfirm bluetuith

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

echo -en '\n\n' >> $HOME/.zshrc
echo "EDITOR=nvim" >> $HOME/.zshrc
echo "VISUAL=nvim" >> $HOME/.zshrc

echo -en '\n\n' >> $HOME/.zshrc
sudo pacman -S --noconfirm neofetch
echo "neofetch" >> $HOME/.zshrc

## install spotify
yay -S --noconfirm spotify

### configuration
CONFIG_DIR=/home/$USER/.config
mkdir -p $CONFIG_DIR

cp -r configs/* $CONFIG_DIR

cd $SW_DIR

## rofi
git clone --depth=1 https://github.com/adi1090x/rofi.git
cd rofi
chmod +x setup.sh
./setup.sh
cd ..
rm -r rofi

sed -i "s/^theme='style-1'/theme='style-5'/g" $CONFIG_DIR/rofi/scripts/launcher_t1


## polybar
git clone --depth=1 https://github.com/adi1090x/polybar-themes.git
cd polybar-themes
chmod +x setup.sh
./setup.sh
cd ..
rm -r polybar-themes


## symlinks
ln -s $CONFIG_DIR/xinit/xinitrc /home/$USER/.xinitrc
ln -s $CONFIG_DIR/alsa/asoundrc /home/$USER/.asoundrc
