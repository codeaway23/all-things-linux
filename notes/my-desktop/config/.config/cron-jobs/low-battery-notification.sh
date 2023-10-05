#!/bin/sh
BAT_PERCENT=$(cat /sys/class/power_supply/BAT0/capacity)

if [ $BAT_PERCENT -le 80 ]; then
	dunstify "BATTERY LOW!" "BATTERY LOW! ==> $BAT_PERCENT % REMAINING" -u critical
fi
