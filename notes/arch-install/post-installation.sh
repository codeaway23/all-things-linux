#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
	echo "Wrong arguments. First(only) argument: hostname"
	exit 1
fi

## Timezone/localtime are already set in the chroot by arch-packages.sh; this
## just turns on NTP so the clock stays correct.
timedatectl set-ntp true
systemctl enable --now systemd-timesyncd

hostnamectl set-hostname "$1"

ETC_HOSTS="127.0.0.1 localhost
::1       localhost
127.0.1.1 $1.localdomain $1"

echo "$ETC_HOSTS" > /etc/hosts
