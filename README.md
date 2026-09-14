# all-things-linux

Arch Linux install + bspwm ricing, scripted end to end.

- [`arch-install/`](arch-install/) — base system: LUKS + LVM + btrfs, GRUB, initramfs
- [`bspwm-setup/`](bspwm-setup/) — desktop: bspwm, polybar, rofi, picom, dotfiles via stow

Rofi and polybar themes are from [adi1090x](https://github.com/adi1090x).

---

## Target hardware

These scripts are written for **my** machine — a **Lenovo Legion 5 Pro 16ACH6H**
(Ryzen 7 5800H + RTX 30-series, 1 TB NVMe). That shows up in a few hardcoded
places you must change on any other machine:

| Assumption | Where | Change to |
|---|---|---|
| Disk is `/dev/nvme0n1` | `lvm-luks-partition.sh`, `grub-install-setup.sh` | your disk from `lsblk` |
| `amd-ucode` | `arch-packages.sh` | `intel-ucode` on Intel |
| `nvidia-open-lts` | `arch-packages.sh` | `nvidia-lts` on Maxwell/Pascal or older; drop entirely on AMD-only |
| AMD iGPU stack (`vulkan-radeon`, `xf86-video-amdgpu`) | `arch-packages.sh` | `vulkan-intel`, `xf86-video-intel` on Intel |
| `acpi_call-dkms` | `arch-packages.sh` | Legion-specific, safe to drop |
| Timezone `Asia/Kolkata`, locale `en_IN.UTF-8` | `arch-packages.sh` | yours |

> **This wipes the disk.** `lvm-luks-partition.sh` runs `mkfs` on three
> partitions with no confirmation prompt. Back up first, and read
> [Step 3](#step-3--partition-and-format) before running anything.

---

## Layout it builds

```
/dev/nvme0n1p1   2G     vfat32    ->  /boot/EFI
/dev/nvme0n1p2   2G     ext4      ->  /boot          (unencrypted)
/dev/nvme0n1p3   rest   LUKS      ->  vg00 (LVM)
                          ├─ lv-root  30G    btrfs  ->  /  (subvolumes @ @root @srv @log @cache @tmp)
                          └─ lv-home  rest   btrfs  ->  /home
```

`/boot` is a **separate unencrypted partition**, so GRUB never has to open the
LUKS container. That means LUKS2 defaults work fine and `GRUB_ENABLE_CRYPTODISK`
stays off. You get one passphrase prompt at boot, from the initramfs.

---

## Step 1 — BIOS and boot media

1. Write the Arch ISO to a USB stick.
2. Reboot into BIOS (**F2** on the Legion, or **Fn+F2**).
3. Set these:
   - **Secure Boot: Disabled** — the install will not proceed otherwise.
   - **Boot Mode: UEFI** (not Legacy/CSM).
4. Boot the USB (**F12** for the boot menu).

Once at the live prompt, confirm you actually booted UEFI:

```bash
ls /sys/firmware/efi/efivars
```

If that errors, you are in Legacy mode — reboot and fix it in BIOS. Everything
below assumes UEFI.

---

## Step 2 — Network in the live environment

Wired: it just works. Wi-Fi:

```bash
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "YOUR_SSID"
[iwd]# exit
```

Verify and sync the clock:

```bash
ping -c3 archlinux.org
timedatectl set-ntp true
```

---

## Step 3 — Partition and format

**First, confirm your disk name.** The scripts hardcode `/dev/nvme0n1`:

```bash
lsblk
```

If your disk is anything else, edit `DISK_EFI`/`DISK_BOOT`/`DISK_ARCH` in
`arch-install/lvm-luks-partition.sh` **and** the `cryptdevice=` line plus the
`/dev/nvme0n1p1` mount in `arch-install/grub-install-setup.sh`.

### 3a. Create the partition table

```bash
cfdisk /dev/nvme0n1
```

Select **gpt** when asked for a label type, then create three partitions:

| # | Size | Type |
|---|---|---|
| 1 | 2G | `EFI System` |
| 2 | 2G | `Linux filesystem` |
| 3 | remaining | `Linux LVM` |

Write the table and quit.

> Give partition 3 **all** the remaining space. `lv-home` is created with
> `100%FREE`, so it only gets what the LUKS container has — a small partition 3
> silently gives you a small `/home`.

### 3b. Get the scripts

```bash
pacman -Sy git
git clone https://github.com/codeaway23/all-things-linux.git
cd all-things-linux/arch-install
```

### 3c. Run it

```bash
bash lvm-luks-partition.sh
```

You will be prompted to:
1. Type `YES` (uppercase) to confirm the LUKS format.
2. Set the **disk encryption passphrase**, twice. You will type this at every
   boot — do not lose it.
3. Enter it once more to unlock.

The script then creates the LVM volumes, formats everything, creates the btrfs
subvolumes, mounts the whole tree under `/mnt`, runs `pacstrap -K`, and generates
`/etc/fstab`.

Sanity check before moving on:

```bash
lsblk
cat /mnt/etc/fstab
```

You should see `/mnt`, `/mnt/home`, `/mnt/boot`, and `/mnt/boot/EFI` mounted.

---

## Step 4 — Base system (inside chroot)

```bash
arch-chroot /mnt
```

Everything from here until Step 5 runs **inside the chroot**. Get the repo in
there too:

```bash
mkdir -p /home/shared
cd /home/shared
git clone https://github.com/codeaway23/all-things-linux.git
cd all-things-linux/arch-install
```

### 4a. Packages, locale, users

```bash
bash arch-packages.sh --name <username> --xorg
```

Use `--wayland` instead of `--xorg` if you want a Wayland stack — but note the
bspwm setup in Step 6 is X11-only, so `--xorg` is what pairs with the rest of
this repo.

This installs the LTS kernel, firmware, NetworkManager, the NVIDIA + AMD iGPU
drivers, sets the timezone and locale, then prompts you to:
1. Set the **root password**.
2. Set the **password for `<username>`**.

It finishes by granting the `wheel` group sudo via a validated
`/etc/sudoers.d/10-wheel` drop-in.

### 4b. Bootloader

```bash
bash grub-install-setup.sh --xorg
```

Installs GRUB to the ESP, points the kernel cmdline at your LUKS container,
enables `os-prober`, and writes `grub.cfg`.

### 4c. Initramfs

```bash
bash initramfs-setup.sh --xorg
```

Adds the `encrypt` + `lvm2` hooks (so the initramfs can unlock your disk), the
`microcode` hook, and NVIDIA early KMS — then rebuilds with `mkinitcpio -P`.

> **Read the output.** If `mkinitcpio` reports an error about the `encrypt` or
> `lvm2` hook, stop and fix it here. A bad initramfs means an unbootable system,
> and you are still in the chroot where it is easy to correct.

### 4d. Reboot

```bash
exit
umount -R /mnt
reboot
```

Pull the USB stick out as it reboots.

---

## Step 5 — First boot

You should get:
1. A GRUB menu.
2. A **passphrase prompt** to unlock the disk.
3. A TTY login.

Log in as **root** and finish up:

```bash
cd /home/shared/all-things-linux/arch-install
bash post-installation.sh <hostname>
```

That enables NTP and sets the hostname and `/etc/hosts`.

Now get networking back — NetworkManager is enabled but nothing is connected yet:

```bash
nmtui
```

(Or `nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"`.) Confirm
with `ping -c3 archlinux.org`.

---

## Step 6 — Desktop

**Log out of root and log in as your normal user.** The desktop script uses
`sudo` and writes into `$HOME`; running it as root puts every dotfile in
`/root`.

The script expects the repo at `~/software/all-things-linux`:

```bash
mkdir -p ~/software
cd ~/software
git clone https://github.com/codeaway23/all-things-linux.git
cd all-things-linux/bspwm-setup
sh install.sh
```

This installs bspwm/sxhkd/polybar/rofi/picom, PipeWire, fonts and themes, builds
`yay`, symlinks all the dotfiles with `stow`, sets up cron jobs, enables
bluetooth and LightDM, and installs the dev tooling.

It is **not** unattended — it will stop for:
- `sudo` passwords
- the `yay` / `makepkg` build prompts
- `chsh` (your password, to switch to zsh)
- the Miniconda installer licence + install path

When it finishes:

```bash
reboot
```

You should land in LightDM. Log in and you are in bspwm.

`Super + Return` opens kitty, `Super + Space` opens the rofi launcher. Full
keybind list is in [`bspwm-setup/config/.config/sxhkd/sxhkdrc`](bspwm-setup/config/.config/sxhkd/sxhkdrc).

---

## Afterwards

A few things the scripts deliberately leave to you:

- **Wallpapers.** The feh cron job reads `~/wallpapers/feh/`. It is empty until
  you put images there, so your desktop will be black.
- **`.xinitrc` is only read by `startx`.** Since LightDM is what launches your
  session, anything you add there needs to go in `~/.xprofile` or `bspwmrc`
  instead.
- **git identity.** `install.sh` sets a global `user.name`/`user.email` — change
  those to yours.

---

## If something goes wrong

**Cannot unlock at boot / dropped to an emergency shell.** The `encrypt` or
`lvm2` hook is missing from the initramfs. Boot the USB again and:

```bash
cryptsetup luksOpen /dev/nvme0n1p3 arch
vgchange -ay
mount -o subvol=@ /dev/vg00/lv-root /mnt
mount /dev/nvme0n1p2 /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot/EFI
arch-chroot /mnt
# fix HOOKS in /etc/mkinitcpio.conf, then:
mkinitcpio -P
```

**No GRUB menu at all.** Boot the USB, chroot as above, and re-run
`grub-install-setup.sh`. Check the ESP is actually mounted at `/boot/EFI` first.

**No network after first boot.** `systemctl status NetworkManager`, then
`nmtui`.

**Black screen after LightDM.** Usually the NVIDIA/AMD hybrid setup. Check
`journalctl -b -u lightdm` and `/var/log/Xorg.0.log`. Booting with
`nvidia_drm.modeset=0` appended in GRUB (press `e` at the menu) narrows it down.
