#! /bin/sh

## minimal sofotware installation for a functional system
sudo pacman -Syu --noconfirm linux-firmware \
	xorg-xinit xorg-xrandr \
	bspwm sxhkd picom \
	kitty alacritty \
	rofi polybar \
	cronie \
	rsync thunar file-roller ranger \
	bluez bluez-utils \
	alsa-utils pulseaudio pulseaudio-bluetooth pamixer pavucontrol pamixer \
	zsh neovim xclip \
	stow \
	lightdm lightdm-gtk-greeter \
	firefox \
	git pygmentize highlight

## fix speakers and microphone
pulseaudio --start

## start bluetooth
rfkill unblock bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

## arch mirrors synchronization
sudo pacman -S --noconfirm reflector
sudo sed -i 's/^--sort .*/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo sed -i 's/^--country .*/--country India/g' /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector.service reflector.timer
sudo systemctl start reflector.service reflector.timer
sudo systemctl start reflector.service

## fonts, icons, themes
sudo pacman -S --noconfirm ttf-iosevka-nerd ttf-inconsolata-nerd \
						   ttf-firacode-nerd ttf-hack-nerd \
						   otf-hasklig-nerd ttf-meslo-nerd \
						   adwaita-icon-theme papirus-icon-theme

git clone https://github.com/snwh/faba-icon-theme.git  
cd faba-icon-theme
sudo pacman -S --noconfirm meson
meson "build" --prefix=/usr
sudo ninja -C "build" install
cd ..
rm -r faba-icon-theme

## oh my zsh + powerline10k
0>/dev/null sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/themes/powerlevel10k
sed -i 's/^ZSH_THEME=\"robbyrussell\"*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' $HOME/.zshrc
sed -i 's/^plugins=(git)*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' $HOME/.zshrc
sed -i 's/.*ENABLE_CORRECTION=\"true\"*/ENABLE_CORRECTION=\"true\"/g' $HOME/.zshrc
chsh -s $(which zsh)

## zshrc 
echo -en '\n\n' >> $HOME/.zshrc
echo "EDITOR=nvim" >> $HOME/.zshrc
echo "VISUAL=nvim" >> $HOME/.zshrc

## where all user software lies
SW_DIR=/home/$USER/software
mkdir -p $SW_DIR

## install AUR package manager 'yay'
cd $SW_DIR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd /home/$USER

### configuration
CONFIG_DIR=/home/$USER/.config
mkdir -p $CONFIG_DIR

# symbolic link manager
stow --dir=$SW_DIR/all-things-linux/notes/my-desktop/config/ --target=/home/$USER .

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

## nvim-plug and dunst
yay -Syu --noconfirm neovim-plug dunst

## set up lightdm
sudo sed -i "s/^greeter-session=.*/greeter-session=lightdm-gtk-greeter/g" /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm -f

## install spotify
yay -S --noconfirm spotify-launcher

