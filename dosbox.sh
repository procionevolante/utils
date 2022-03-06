#!/bin/sh
# this shell script is needed in order to be able to use DOSbox when there are
# multiple monitors. (Apparently DOSBox uses an old version of SDL that doesn't
# work well in these cases)
#
# it starts dosbox in the "primary" monitor, if you didn't set the primary
# monitor (or "output", in X terminology) set this command to run at startup:
#  xrandr --output my_cool_monitor_name --primary
# you can get the cool monitor names with "xrandr" without arguments
# (and even names of not-cool monitors)

# OPTIONS
output_fallback=DVI-1
# ---

source secrets

mountpoint -q "$freedos_mnt_dir"
if [ $? -ne 0 ]; then
	mount "$freedos_mnt_dir"
fi

output=$(xrandr|grep primary|cut -d ' ' -f 1)
[ -n "$output" ] && output=$output_fallback

Xephyr :1 -title DOSbox -output "$output" &
xnest_pid=$!

# if there wasn't this sleep the display would go nuts
sleep 1
env DISPLAY=:1 dosbox -fullscreen
kill $!
