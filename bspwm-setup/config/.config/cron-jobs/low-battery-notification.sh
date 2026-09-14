#!/bin/sh
# cron has no session bus, so dunstify cannot reach the notification daemon
# without being pointed at the user bus explicitly.
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

BAT=/sys/class/power_supply/BAT0
[ -r "$BAT/capacity" ] || exit 0

BAT_PERCENT=$(cat "$BAT/capacity")
BAT_STATUS=$(cat "$BAT/status" 2>/dev/null)

if [ "$BAT_STATUS" != "Charging" ] && [ "$BAT_PERCENT" -le 20 ]; then
	dunstify "BATTERY LOW!" "BATTERY LOW! ==> $BAT_PERCENT % REMAINING" -u critical
fi
