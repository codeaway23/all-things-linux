#!/bin/bash

# brightnessctl replaces xbacklight: xbacklight only drives displays that expose
# the RandR Backlight property, which modern intel/amdgpu/nvidia KMS drivers
# generally do not. brightnessctl writes /sys/class/backlight directly and is
# given access via its udev rules, so no root is needed.

function get_brightness {
  brightnessctl -m | cut -d',' -f4 | tr -d '%'
}

function send_notification {
    bright=$(get_brightness)
	icon_name="/usr/share/icons/Papirus/24x24/apps/preferences-system-brightness-lock.svg"
	bar=$(seq -s "─" $(($bright/5)) | sed 's/[0-9]//g')
	dunstify "$bright""     ""$bar" -i "$icon_name" -t 2000 -h string:synchronous:"$bar" --replace=555
}

case $1 in
  up)
    brightnessctl set 5%+ -q
    send_notification
    ;;
  down)
    brightnessctl set 5%- -q
    send_notification
    ;;
esac
