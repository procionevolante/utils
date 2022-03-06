#!/bin/dash
# a script that uses libnotify to display the volume in a desktop notification
# works with ALSA and pulseaudio with ALSA backend

lock_file="/tmp/ALSAvolumenotifyLOCK.$DISPLAY"

# check that only one instance is running
[ -e "$lock_file" ] && kill -0 "$(cat "$lock_file")" &&
	exit
	# we exit because a running instance was found
	# note that kill -0 PID only checks if the process is still running
echo $$ > "$lock_file"
trap "rm -f \"$lock_file\"" INT TERM EXIT

# user configuration
base_img='/usr/share/icons/Adwaita/32x32/status/audio-volume'
high_img="$base_img-high-symbolic.symbolic.png"
medium_img="$base_img-medium-symbolic.symbolic.png"
low_img="$base_img-low-symbolic.symbolic.png"
muted_img="$base_img-muted-symbolic.symbolic.png"
high_thr=50
medium_thr=20
low_thr=10
timeout=2000
last_id_file="/tmp/ALSAvolumenotifyID.$DISPLAY"
# -------------

[ ! -f "$last_id_file" ] && echo 0 > "$last_id_file"
state="$(amixer sget Master | nawk '/ Left: /{tmp=$5"\t"$6; gsub(/[\[\]%]/,"",tmp); print tmp}')"
# state= (volume, muted)
vol=$(echo "$state" | cut -f 1)
mute=$(echo "$state" | cut -f 2)
lastid="$(cat "$last_id_file")"

if [ $mute = "off" ]; then
	img="$muted_img"
elif [ $vol -ge $high_thr ]; then
	img="$high_img"
elif [ $vol -ge $medium_thr ]; then
	img="$medium_img"
else
	img="$low_img"
fi

id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \
	"volumenotification" "$lastid" "$img" "$vol%" '' '[]' "{\"value\": <int32 $vol>}" "int32 $timeout" \
	| sed 's/(uint32 \([0-9]\+\),)/\1/g' )

[ "$id" -ne "$lastid" ] &&  echo $id > "$last_id_file"

# you can also use notify-send.sh to have a much shorter command
#id=$(notify-send.sh -p -t "$timeout" -i "$img" -r "$lastid" -h "int:value:${state[0]}" "${state[0]}%" | tr -Cd '[:digit:]')
