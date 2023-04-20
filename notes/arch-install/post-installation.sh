#!/bin/sh

if [ $# -ne 1 ]; then
	echo "Wrong arguments. First(only) argument: hostname"
	exit
fi

timedatectl set-timezone Asia/Calcutta
systemctl enable systemd-timesyncd

hostnamectl set-hostname $1

ETC_HOSTS="127.0.0.1 localhost $1
::1 localhost $1"

echo "$ETC_HOSTS" > /etc/hosts
