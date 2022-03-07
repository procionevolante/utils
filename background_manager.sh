#!/bin/bash
# simple background manager with automatic changing.
# Tested on sway and i3wm
source ~/bin/secrets
imgdir="${background_img_dir}"
interval=10m
declare -a imgs

while read -er img; do
	imgs+=("$img")
done << EOF
$(find "$imgdir" -iname "*.jpg" -o -iname "*.png" | shuf)
EOF

echo "${#imgs[@]} image(s) found in '$imgdir'"

if [ -n "$SWAYSOCK" ]; then
	# for wayland/sway
	echo sway mode
	let i=0
	# exit the script when we exit/restart sway
	(swaymsg -q -t subscribe '[ "shutdown" ]'; kill $$) &
	# continue until sway stops (failsafe for the kill on the line above)
	while swaymsg -q -t get_version; do
		screens="$(swaymsg -t get_outputs | grep -F '"name":' | cut -d '"' -f 4)"
		for scr in $screens; do
			swaymsg output $scr bg "${imgs[$i]}" fill
			let "i=(i+1)%${#imgs[@]}"
		done
		sleep "$interval"
	done
elif [ -n "$DISPLAY" ]; then
	# for X with i3
	# sets a random background on every connected screen
	echo i3 mode
	# exit the script when we exit/restart i3
	# note that this command only works because the shell expands $$ BEFORE
	# executing `kill` (damn bash you're strange)
	i3-msg -q -t subscribe '[ "shutdown" ]' && kill $$ &
	let i=0
	while i3-msg -q -t get_version; do
		let nscreens=$(xrandr | grep -F " connected " | wc -l)
		feh --no-fehbg --bg-fill "${imgs[@]:$i:$nscreens}"
		let "i=(i+nscreens)%${#imgs[@]}"
		sleep "$interval"
	done
fi

# the still-works-but-ugly method:
#feh --no-fehbg --bg-fill $( \
#	ls /mnt/condivisione/immagini/sfondi/* | shuf \
#	| head -n $(xrandr | grep -v disconnected | grep connected | wc -l) \
#)

