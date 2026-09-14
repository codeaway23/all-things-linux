#! /bin/sh
set -eu

## where all user software lies
SW_DIR="$HOME/software"
REPO_DIR="$SW_DIR/all-things-linux"
mkdir -p "$SW_DIR"

## minimal software installation for a functional system
## audio: pipewire replaces pulseaudio. pipewire-pulse provides the same
## pactl/pamixer interface, wireplumber is the session manager (it handles
## bluetooth auto-switching, so /etc/pulse/default.pa tweaks are not needed).
## brightnessctl replaces xorg-xbacklight, which only works on drivers exposing
## the RandR Backlight property and is a coin flip on modern intel/amdgpu.
## nerd fonts moved into [extra] and no longer need the AUR.
sudo pacman -S --needed \
	linux-firmware \
	xorg-xinit xorg-xrandr xorg-xinput xorg-xsetroot xorg-xrdb \
	bspwm sxhkd \
	alacritty kitty \
	picom \
	rofi \
	polybar \
	feh \
	btrfs-progs ntfs-3g rsync thunar file-roller \
	bluez bluez-utils \
	pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
	alsa-utils pavucontrol pamixer \
	brightnessctl \
	dunst libnotify \
	ranger python-pygments highlight \
	zsh neovim xclip stow \
	lightdm lightdm-slick-greeter \
	lxappearance \
	fastfetch \
	spotify-launcher \
	gsfonts \
	ttf-firacode-nerd ttf-hack-nerd ttf-inconsolata-nerd ttf-iosevka-nerd ttf-meslo-nerd \
	adwaita-icon-theme papirus-icon-theme breeze

## set up lightdm
sudo sed -i "s/^#\?greeter-session=.*/greeter-session=lightdm-slick-greeter/g" /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm -f

## install AUR package manager 'yay'
if ! command -v yay >/dev/null 2>&1; then
	cd "$SW_DIR"
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
	cd "$HOME"
fi

## set up some software
yay -S --needed --noconfirm neovim-plug wps-office firefox brave-bin

## gtk themes and icons
yay -S --needed --noconfirm \
	catppuccin-gtk-theme-mocha \
	catppuccin-gtk-theme-macchiato \
	catppuccin-gtk-theme-frappe \
	catppuccin-gtk-theme-latte \
	ttf-wps-fonts

## install faba icons for dunst brightness/volume bar
cd "$SW_DIR"
git clone https://github.com/snwh/faba-icon-theme.git
cd faba-icon-theme
sudo pacman -S --needed --noconfirm meson
meson setup "build" --prefix=/usr
sudo ninja -C "build" install
cd "$SW_DIR"
rm -rf faba-icon-theme

## shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
[ -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ] || \
	git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
[ -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ] || \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"
[ -d "$HOME/.oh-my-zsh/themes/powerlevel10k" ] || \
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/themes/powerlevel10k"
sed -i 's/^ZSH_THEME=\"robbyrussell\"*/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' "$HOME/.zshrc"
sed -i 's/^plugins=(git)*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$HOME/.zshrc"
sed -i 's/.*ENABLE_CORRECTION=\"true\"*/ENABLE_CORRECTION=\"true\"/g' "$HOME/.zshrc"
chsh -s "$(which zsh)"

grep -q "^export EDITOR=nvim" "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'ZSHRC'

export EDITOR=nvim
export VISUAL=nvim

fastfetch
ZSHRC

### configuration
mkdir -p "$HOME/.config"

## symbolic link manager
stow --dir="$REPO_DIR/notes/bspwm-setup/config/" --target="$HOME" .

## set up cronjobs -- idempotent, appends only if the entry is not already there
sudo pacman -S --needed --noconfirm cronie
sudo systemctl enable --now cronie
for JOB in \
	"*/15 * * * * /bin/sh $HOME/.config/cron-jobs/feh-dynamic-wallpaper.sh" \
	"*/5 * * * * /bin/sh $HOME/.config/cron-jobs/low-battery-notification.sh"
do
	(crontab -l 2>/dev/null || true; echo "$JOB") | sort -u | crontab -
done

## arch mirrors synchronization
sudo pacman -S --needed --noconfirm reflector
sudo sed -i 's/^--sort .*/--sort rate/g' /etc/xdg/reflector/reflector.conf
sudo sed -i 's/^--country .*/--country India/g' /etc/xdg/reflector/reflector.conf
sudo systemctl enable --now reflector.timer

## start bluetooth
rfkill unblock bluetooth
sudo systemctl enable --now bluetooth

## audio: pipewire is socket-activated per user, just make sure it is enabled
systemctl --user enable --now pipewire pipewire-pulse wireplumber

## realtime audio limits.
## NOTE: `sudo echo x >> file` does NOT work -- the redirect is performed by the
## unprivileged shell, not by sudo. Use tee.
printf '@audio - memlock unlimited\n@audio - rtprio unlimited\n' | sudo tee /etc/security/limits.d/99-audio.conf >/dev/null
## -a is essential: `usermod -G` REPLACES every supplementary group, which would
## silently drop you from video/storage/docker/etc.
sudo usermod -aG audio "$USER"
yay -S --needed --noconfirm helm-synth

## Legion 5 Pro 16ACH6H specifics.
## brightnessctl needs the user in the video group to write /sys/class/backlight
## when its udev rules are not picked up.
sudo usermod -aG video "$USER"
## fan curves, power modes and battery conservation mode for the Legion.
## Needs linux-lts-headers (installed by arch-packages.sh) to build the module.
yay -S --needed --noconfirm lenovolegionlinux-dkms-git
## power management -- Ryzen laptops idle much better with tlp than without.
sudo pacman -S --needed --noconfirm tlp powertop
sudo systemctl enable --now tlp

## work - dev tools
DL_DIR="$HOME/Downloads"
mkdir -p "$DL_DIR"
cd "$DL_DIR"
## work miniconda setup
curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
## work - ELK stack. Pin whatever version you actually want; "latest" here so the
## URLs do not rot the way the hardcoded 8.9.0 ones did.
ELK_VERSION=${ELK_VERSION:-9.2.0}
for COMPONENT in elasticsearch kibana; do
	curl -L -O "https://artifacts.elastic.co/downloads/$COMPONENT/$COMPONENT-$ELK_VERSION-linux-x86_64.tar.gz"
	curl -L -O "https://artifacts.elastic.co/downloads/$COMPONENT/$COMPONENT-$ELK_VERSION-linux-x86_64.tar.gz.sha512"
	shasum -a 512 -c "$COMPONENT-$ELK_VERSION-linux-x86_64.tar.gz.sha512"
	tar -xzf "$COMPONENT-$ELK_VERSION-linux-x86_64.tar.gz"
done
# work - databases, docker
sudo pacman -S --needed --noconfirm postgresql mariadb \
                           rclone \
                           docker docker-compose docker-buildx
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
yay -S --needed --noconfirm postman-bin \
                    mongodb-bin
## work - vs-codium
yay -S --needed --noconfirm vscodium-bin
## work - R and RStudio
sudo pacman -S --needed --noconfirm r
yay -S --needed --noconfirm rstudio-desktop-bin
## work - slack, discord
yay -S --needed --noconfirm slack-desktop
sudo pacman -S --needed --noconfirm discord
## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "anujsablework@gmail.com"
git config --global init.defaultBranch main
