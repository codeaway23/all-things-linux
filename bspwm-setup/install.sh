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
## accountsservice is only an OPTDEPEND of lightdm, so pacman does not pull
## it in -- but slick-greeter needs org.freedesktop.Accounts to enumerate
## users. Without it the greeter logs "ServiceUnknown: The name is not
## activatable" and the session fails to start after you enter your password.
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
	lightdm lightdm-slick-greeter accountsservice \
	lxappearance \
	fastfetch \
	spotify-launcher \
	gsfonts \
	ttf-firacode-nerd ttf-hack-nerd ttf-inconsolata-nerd ttf-iosevka-nerd ttf-meslo-nerd \
	adwaita-icon-theme papirus-icon-theme breeze

## set up lightdm.
## user-session matters: it defaults to "default", which looks for a
## default.desktop that does not exist, and lightdm then reports
## "Failed to start session" after accepting your password.
sudo sed -i "s/^#\?greeter-session=.*/greeter-session=lightdm-slick-greeter/g" /etc/lightdm/lightdm.conf
sudo sed -i "s/^#\?user-session=.*/user-session=bspwm/g" /etc/lightdm/lightdm.conf

## AccountsService stores a PER-USER session preference that lightdm reads in
## preference to user-session above. It defaults to "default", which points at a
## default.desktop that does not exist -- lightdm then accepts your password,
## fails to spawn anything, and reports "Failed to start session" while the
## journal fills with "Error writing to session: Broken pipe".
## Seed it so the very first login works.
AS_USER="/var/lib/AccountsService/users/$USER"
sudo mkdir -p /var/lib/AccountsService/users
if sudo test -f "$AS_USER"; then
	if sudo grep -q '^XSession=' "$AS_USER"; then
		sudo sed -i 's|^XSession=.*|XSession=bspwm|' "$AS_USER"
	else
		printf 'XSession=bspwm\n' | sudo tee -a "$AS_USER" >/dev/null
	fi
else
	printf '[User]\nXSession=bspwm\nSystemAccount=false\n' | sudo tee "$AS_USER" >/dev/null
fi
sudo systemctl try-restart accounts-daemon

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
[ -d "$HOME/.oh-my-zsh" ] || \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
[ -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ] || \
	git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
[ -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ] || \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"
[ -d "$HOME/.oh-my-zsh/themes/powerlevel10k" ] || \
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/themes/powerlevel10k"
## These replace the WHOLE line rather than pattern-matching the old value, so
## re-running the script is safe. The previous `s/^plugins=(git)*/.../` was not:
## in a BRE `)*` means "zero or more )", so on a second run it matched the
## already-edited line and appended the plugins again, producing an unbalanced
## paren and a .zshrc parse error -- which breaks login shells.
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
sed -i 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' "$HOME/.zshrc"
sed -i 's|^[# ]*ENABLE_CORRECTION=.*|ENABLE_CORRECTION="true"|' "$HOME/.zshrc"
## refuse to continue with a broken .zshrc rather than discover it at login
zsh -n "$HOME/.zshrc"
[ "$(getent passwd "$USER" | cut -d: -f7)" = "$(which zsh)" ] || chsh -s "$(which zsh)"

grep -q "^export EDITOR=nvim" "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'ZSHRC'

export EDITOR=nvim
export VISUAL=nvim

fastfetch
ZSHRC

### configuration
mkdir -p "$HOME/.config"

## symbolic link manager
stow --dir="$REPO_DIR/bspwm-setup/config/" --target="$HOME" .

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
## pam ships /etc/security/limits.conf but NOT the limits.d/ directory, so it
## does not exist on a fresh Arch install and tee cannot create the file in it.
sudo mkdir -p /etc/security/limits.d
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
