#!/bin/bash

function get_brightness {
  xbacklight -get | sed 's/[.].*//g'
}

function send_notification {
    DIR=`dirname "$0"`
    bright=`get_brightness`
	icon_name="/usr/share/icons/Papirus/24x24/apps/preferences-system-brightness-lock.svg"
	bar=$(seq -s "─" $(($bright/5)) | sed 's/[0-9]//g')
	dunstify "$bright""     ""$bar" -i "$icon_name" -t 2000 -h string:synchronous:"$bar" --replace=555
}

case $1 in
  up)
    xbacklight -inc 5
    send_notification
    ;;
  down)
    xbacklight -dec 5
    send_notification
    ;;
esac
