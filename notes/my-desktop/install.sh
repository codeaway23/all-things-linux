#! /bin/sh

## minimal sofotware installation for a functional system
sudo pacman -Syu linux-firmware \
	xorg-xinit xorg-xrandr \
	bspwm sxhkd \
	alacritty kitty \
	picom \
	rofi \
	polybar \
	btrfs-progs ntfs-3g rsync thunar file-roller \
	bluez bluez-utils \
	alsa-utils pulseaudio pulseaudio-bluetooth pavucontrol pamixer \
	ranger zsh neovim xclip stow \
	lightdm lightdm-gtk-greeter \
	cronie

## set up lightdm
sudo sed -i "s/^greeter-session=.*/greeter-session=lightdm-gtk-greeter/g" /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm -f

## where all user software lies
SW_DIR=/home/$USER/software
mkdir -p $SW_DIR

## install AUR package manager 'yay'
cd $SW_DIR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd /home/$USER

## set up some software
yay -Syu --noconfirm neovim-plug dunst

## install brave browser
yay -Syu --noconfirm brave-bin 

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

## shell, font and theme
sudo pacman -S --noconfirm zsh gsfonts
yay -S --noconfirm powerline-fonts-git ttf-font-awesome ttf-jetbrains-mono \
                   ttf-fira-code ttf-iosevka ttf-monoid otf-hasklig \
                   ttf-ms-fonts noto-fonts-emoji \
				   ttf-firacode-nerd

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
yay -S --noconfirm spotify-launcher

### configuration
CONFIG_DIR=/home/$USER/.config
mkdir -p $CONFIG_DIR

## install faba icons for dunst brightness/volume bar
git clone https://github.com/snwh/faba-icon-theme.git  
cd faba-icon-theme
sudo pacman -S --noconfirm meson
meson "build" --prefix=/usr
sudo ninja -C "build" install
cd ..
rm -r faba-icon-theme

## symbolic link manager
stow --dir=$SW_DIR/all-things-linux/notes/my-desktop/config/ --target=/home/$USER .

## set up cronjobs
crontab -l > mycron
echo "*/15 * * * * /bin/sh /home/anuj/.config/cron-jobs/feh-dynamic-wallpaper.sh" >> mycron
echo "*/5 * * * * /bin/sh /home/anuj/.config/cron-jobs/low-battery-notification.sh" >> mycron
crontab mycron
rm mycron

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

## for ranger
sudo pacman -Syu pygmentize highlight


## set up audio for bluetooth and synth
sudo usermod -G users,wheel,audio $USER
sudo echo "@audio - memlock unlimited" >> /etc/security/limits.conf
sudo echo "@audio - rtprio unlimited" >> /etc/security/limits.conf
sudo echo "load-module module-switch-on-connect" >> /etc/pulse/default.pa
sudo pacman -Syu helm-synth


# reboot
