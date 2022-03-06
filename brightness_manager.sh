#!/bin/sh
# Monitors the screen brightness level (and show a desktop notification)
# Once started, the script is controlled by writing some text to the named pipe
#  /tmp/brightness_control.$DISPLAY
# if a '+' is written to the pipe, the brighness level increases
# if a '-' is written to the pipe, the brighness level decreases

# -- user config --
# use this icon in the notification
icon='display-brightness-symbolic'
# hide notification after these milliseconds
timeout=2000
# increase and decrease brightness of this percentage
change_level=5
# -----------------
# id of the last notification
lastid=0
mainPID=$$
pipe="/tmp/brightness_control.$DISPLAY"
[ -e "$pipe" ] && rm "$pipe"
if ! mkfifo "$pipe"; then
	echo "couldn't create pipe '$pipe'" > /dev/stderr
	exit 1
fi
chmod 600 "$pipe"

onexit() {
	echo exiting...
	rm "$pipe"
	#kill %1
	exit
}

trap onexit TERM INT QUIT
( swaymsg -q -t subscribe '[ "shutdown" ]'; kill $mainPID )&

br_max=$(brightnessctl m)

while true; do
	read op < "$pipe"
	case $op in
		+|-)
			brightnessctl s ${change_level}%${op} ;;
		*)
			echo "'$op' is not a valid operation" > /dev/stderr ;;
	esac
	br_now=$(brightnessctl g)
	percentage=$((($br_now*100) / $br_max))
	
	id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \
		"volumenotification" "$lastid" "$icon" "${percentage}%" '' '[]' "{\"value\": <int32 ${percentage}>}" "int32 $timeout" \
		| sed 's/(uint32 \([0-9]\+\),)/\1/g' )
	if [ $lastid -ne $id ]; then
		lastid=$id
	fi
done

echo "We shouldn't arrive here, check your code" > /dev/stderr
onexit
