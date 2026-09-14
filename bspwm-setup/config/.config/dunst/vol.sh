#!/bin/bash

function get_volume() {
  pamixer --get-volume
}

function is_mute() {
	echo $(pamixer --get-mute)
}

function send_notification() {
    volume=`get_volume`
	mute=$(is_mute)

	if [[ "$volume" -eq "0" || "$mute" == "true" ]]; then
		icon_name="/usr/share/icons/Papirus-Light/24x24/panel/audio-volume-muted-panel.svg"
	elif [ "$volume" -lt "30" ]; then
		icon_name="/usr/share/icons/Papirus-Light/24x24/panel/audio-volume-low-panel.svg"
	elif [ "$volume" -lt "70" ]; then
		icon_name="/usr/share/icons/Papirus-Light/24x24/panel/audio-volume-medium-panel.svg"
	else 
		icon_name="/usr/share/icons/Papirus-Light/24x24/panel/audio-volume-high-panel.svg"
	fi

	bar=$(seq -s "─" $(($volume/5)) | sed 's/[0-9]//g')
	# Send the notification
	dunstify "$volume""     ""$bar" -i "$icon_name" -t 2000 -h string:synchronous:"$bar" --replace=555
}

case $1 in
  up)
	mute=$(is_mute)
	if [ "$mute" == "true" ]; then
		pamixer -t
	fi
    pamixer -i 5
    send_notification
    ;;
  down)
	mute=$(is_mute)
	if [ "$mute" == "true" ]; then
		pamixer -t
	fi
    pamixer -d 5
    send_notification
    ;;
  mute)
    pamixer -t
    send_notification
    ;;
esac
