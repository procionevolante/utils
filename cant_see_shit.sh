#!/bin/sh
# a script that runs the termite terminal emulator stylized in a way that makes
# it actually possible to see something when the sun shines
tempcfg="/tmp/cantseeshit.$$"
set -e

cp "$HOME/.config/termite/config" "$tempcfg"
cat >> "$tempcfg" <<- 'EOF'
	[colors]
	foreground      = #000000
	foreground_bold = #000000
	background      = #ffffff
	# R
	color1          = #dd0000
	color9          = #ff0000
	# G
	color2          = #00dd00
	color10         = #00ff00
	# B
	color4          = #0000dd
	color12         = #0000ff
	# cyan
	color6          = #00dddd
	color14         = #00ffff
	EOF
termite -c "$tempcfg"&
sleep 3
rm "$tempcfg"
