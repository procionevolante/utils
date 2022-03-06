#!/bin/sh
curr_layout="$(setxkbmap -query | awk '/^layout:/{print $2}')"
if [ "$curr_layout" = us ]; then
	# if the keyboard layout is AMERICAN:
	setxkbmap -layout it
	if [ -n "$SWAYSOCK" ]; then
		swaymsg input '*' xkb_variant ''
		swaymsg input '*' xkb_layout it
	fi
else
	# if the keyboard layout is ITALIAN (or something else)
	# sets the US keyboard layout, with dead keys on altgr
	setxkbmap -layout us -variant altgr-intl
	if [ -n "$SWAYSOCK" ]; then
		swaymsg input '*' xkb_layout us
		swaymsg input '*' xkb_variant altgr-intl
	fi
fi
