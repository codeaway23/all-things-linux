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
	lightdm lightdm-slick-greeter \
	lxappearance cronie 

## set up lightdm
sudo sed -i "s/^greeter-session=.*/greeter-session=lightdm-slick-greeter/g" /etc/lightdm/lightdm.conf
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
yay -Syu --noconfirm neovim-plug dunst wps-office firefox brave-bin 

## gtk themes and icons
yay -S catppuccin-gtk-theme-mocha \
	catppuccin-gtk-theme-macchiato \
	catppuccin-gtk-theme-frappe \
	catppuccin-gtk-theme-latte \
	adwaita-cursors-git \
	xcursor-breeze \
	adwaita-icon-theme \
	breeze-faba-icon-theme \
	papirus-icon-theme

## install faba icons for dunst brightness/volume bar
git clone https://github.com/snwh/faba-icon-theme.git  
cd faba-icon-theme
sudo pacman -S --noconfirm meson
meson "build" --prefix=/usr
sudo ninja -C "build" install
cd ..
rm -r faba-icon-theme

## shell, font and theme
sudo pacman -S --noconfirm zsh gsfonts
yay -S --noconfirm  ttf-firacode-nerd \
	ttf-hack-nerd \
	ttf-inconsolata-nerd \
	ttf-iosevka-nerd \
	ttf-meslo-nerd \
	ttf-wps-fonts  


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

## symbolic link manager
stow --dir=$SW_DIR/all-things-linux/notes/my-desktop/config/ --target=/home/$USER .

## set up cronjobs
crontab -l > mycron
echo "*/15 * * * * /bin/sh /home/anuj/.config/cron-jobs/feh-dynamic-wallpaper.sh" >> mycron
echo "*/5 * * * * /bin/sh /home/anuj/.config/cron-jobs/low-battery-notification.sh" >> mycron
crontab mycron
rm mycron

## for ranger
sudo pacman -Syu pygmentize highlight

## set up crontab
(crontab -l ; echo "*/15 * * * * /bin/sh /home/anuj/.config/cron-jobs/feh-dynamic-wallpaper.sh")| crontab -
(crontab -l ; echo "*/5 * * * * /bin/sh /home/anuj/.config/cron-jobs/low-battery-notification.sh")| crontab -

## arch mirrors synchronization
sudo pacman -S --noconfirm reflector
sudo sed -i 's/^--sort .*/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo sed -i 's/^--country .*/--country India/g' /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector.service reflector.timer
sudo systemctl start reflector.service reflector.timer
sudo systemctl start reflector.service

## fix speakers and microphone
pulseaudio --start

## start bluetooth
rfkill unblock bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

## set up audio for bluetooth and synth
sudo usermod -G users,wheel,audio $USER
sudo echo "@audio - memlock unlimited" >> /etc/security/limits.conf
sudo echo "@audio - rtprio unlimited" >> /etc/security/limits.conf
sudo echo "load-module module-switch-on-connect" >> /etc/pulse/default.pa
sudo pacman -Syu helm-synth

## work - dev tools
DL_DIR=/home/$USER/Downloads
mkdir -p $DL_DIR
cd $DL_DIR
## work miniconda setup
curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
## work - ELK stack
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-8.9.0-linux-x86_64.tar.gz.sha512 
tar -xzf elasticsearch-8.9.0-linux-x86_64.tar.gz

curl -O https://artifacts.elastic.co/downloads/kibana/kibana-8.9.0-linux-x86_64.tar.gz
curl https://artifacts.elastic.co/downloads/kibana/kibana-8.9.0-linux-x86_64.tar.gz.sha512 | shasum -a 512 -c - 
tar -xzf kibana-8.9.0-linux-x86_64.tar.gz
# work - databases, docker
sudo pacman -S --noconfirm postgresql mariadb \
                           rclone \
                           docker docker-compose
yay -S --noconfirm  postman-bin \
                    mongodb-bin
## work - vs-codium
yay -S --noconfirm vscodium
## work - R and RStudio
yay -S --noconfirm r rstudio-desktop
## work - slack, discord
yay -S --noconfirm slack-desktop discord
## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "anujsablework@gmail.com"
git config --global init.defaultBranch main
