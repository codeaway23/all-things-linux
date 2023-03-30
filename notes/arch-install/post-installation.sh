#!/bin/sh

YOUR_HOSTNAME=overdrive

timedatectl set-timezone Asia/Calcutta
systemctl enable systemd-timesyncd

hostnamectl set-hostname $YOUR_HOSTNAME

ETC_HOSTS = "127.0.0.1 localhost $YOUR_HOSTNAME
::1 localhost $YOUR_HOSTNAME"

echo "$ETC_HOSTS" > /etc/hosts

pacman -Syu amd-ucode \
            nvidia-lts nvidia-utils \
            xorg
