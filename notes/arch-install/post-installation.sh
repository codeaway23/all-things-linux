#!/bin/sh

timedatectl set-timezone Asia/Calcutta
systemctl enable systemd-timesyncd

hostnamectl set-hostname overdrive

ETC_HOSTS = "127.0.0.1 localhost overdrive
::1 localhost overdrive"
echo "$ETC_HOSTS" > /etc/hosts

pacman -Syu amd-ucode \
            nvidia-lts nvidia-utils \
            xorg-server
