#!/bin/sh
# Manages the pulseaudio volume level and show a desktop notification when a
# supported command is issued.
# Command are issued by writing them to the named pipe
#  /tmp/pulse_volume_manager.$DISPLAY

# Available commands are:
# +	increase the volume by $raise_lvl
# -	decrease the volume by $lower_lvl
# m	(case insensitive) mute the volume
# u	(case insensitive) unmute the volume
# t	(case insensitive) toggle mute

# -- user config --
# --- icon names ---
base_img='audio-volume'
overamp_img="$base_img-overamplified-symbolic"
high_img="$base_img-high-symbolic"
medium_img="$base_img-medium-symbolic"
low_img="$base_img-low-symbolic"
muted_img="$base_img-muted-symbolic"
# --- thresholds ---
high_thr=60
medium_thr=25
low_thr=10
# --- raise/lower volume of this percentage
raise_lvl=2
lower_lvl=2
# --- after how many milliseconds should the notification disappear? ---
timeout=2000
# --- maximum volume (in percentage)
vol_cap=150
# -----------------

# id of the last volume notification
lastid=0
mainPID=$$
pipe="/tmp/pulse_volume_manager.$DISPLAY"
[ -e "$pipe" ] && rm "$pipe"
mkfifo "$pipe"
[ $? -ne 0 ] && echo "couldn't create pipe '$pipe'" && exit 1
chmod 600 "$pipe"

# $1 = ...
# + -> raise volume
# - -> lower volume
# m/M -> mute volume
# u/U -> unmute volume
# t/T -> toggle (mute/unmute) volume
# prints:
#  if unmuted -> "u [volume_level]"
#  if muted   -> "m [volume_level]"
elaborate_op() {
	case "$1" in
		m|M) # mute
			ponymix mute
			return 0
			;;
		u|U) # unmute
			ponymix unmute
			return 1
			;;
		t|T) # toggle
			ponymix toggle ;;
		+) # increase
			ponymix --max-volume "$vol_cap" increase "$raise_lvl" ;;
		-) # decrease
			ponymix --max-volume "$vol_cap" decrease "$lower_lvl" ;;
		*) # error, unsupported operation
			echo "error: '$1' is an unsupported operation" > /dev/stderr
			ponymix get-volume
			;;
	esac

	# returns 0 if muted, != 0 if unmuted
	ponymix is-muted
	return $?
}

onexit() {
	echo exiting...
	rm "$pipe"
	#kill %1
	exit
}

trap onexit TERM INT QUIT
( swaymsg -q -t subscribe '[ "shutdown" ]'; kill $mainPID )&

while true; do
	read op < "$pipe"
	lvl=$(elaborate_op "$op")
	pwr=$?
	
	# setting img
	if [ "$pwr" -eq 0 ]; then
		img="$muted_img"
	elif [ "$lvl" -gt 100 ]; then
		img="$overamp_img"
	elif [ "$lvl" -ge $high_thr ]; then
		img="$high_img"
	elif [ "$lvl" -ge $medium_thr ]; then
		img="$medium_img"
	else
		img="$low_img"
	fi
	
	id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \
		"volumenotification" "$lastid" "$img" "${lvl}%" '' '[]' "{\"value\": <int32 ${lvl}>}" "int32 $timeout" \
		| sed 's/(uint32 \([0-9]\+\),)/\1/g' )
	if [ $lastid -ne $id ]; then
		lastid=$id
	fi
done

echo "we shouldn't arrive here, check your code"
onexit
