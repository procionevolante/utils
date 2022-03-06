#!/usr/bin/bash
# a script that uses libnotify to display the volume in a desktop notification
# works with ALSA and pulseaudio with ALSA backend

last_id_file="/tmp/ALSAvolumenotifyID.$DISPLAY"

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
# -------------

[ ! -f "$last_id_file" ] && echo 0 > "$last_id_file"
state=($(amixer sget Master | awk '/ Left: /{tmp=$5" "$6; gsub(/[\[\]%]/,"",tmp); print tmp}'))
# state= (volume, muted)
lastid="$( < "$last_id_file")"

if [ ${state[1]} = "off" ]; then
	img="$muted_img"
elif [ ${state[0]} -ge $high_thr ]; then
	img="$high_img"
elif [ ${state[0]} -ge $medium_thr ]; then
	img="$medium_img"
else
	img="$low_img"
fi

#id=$(notify-send.sh -p -t "$timeout" -i "$img" -r "$lastid" -h "int:value:${state[0]}" "${state[0]}%" | tr -Cd '[:digit:]')
id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \
	"volumenotification" "$lastid" "$img" "${state[0]}%" '' '[]' "{\"value\": <int32 ${state[0]}>}" "int32 $timeout" \
	| sed 's/(uint32 \([0-9]\+\),)/\1/g' )

[ "$id" -ne "$lastid" ] &&  echo $id > "$last_id_file"
