#!/bin/sh

OLD_BAT_PERCENT=0
while :
do
	BAT_PERCENT=$(cat /sys/class/power_supply/BAT0/capacity)
	if [ $BAT_PERCENT -lt $OLD_BAT_PERCENT ] && [ $BAT_PERCENT -eq 10 ]; then
		dunstify "BATTERY LOW!" "BATTERY LOW! ==> 10% REMAINING" -u critical
	fi
	OLD_BAT_PERCENT=$BAT_PERCENT
done

