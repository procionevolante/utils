#!/bin/sh
# turns off the integrated screen and sets the biggest screen as primary

# integrated laptop screen, usually it's something like LVDS1, eDP, ...
int_screen='eDP'

main=$(
xrandr | awk '$2=="connected",$1=="640x480"{
	if ($2 == "connected"){
		output=$1
		#print "analyzing " output
	}
	if ($1 ~ /^[1-9][0-9]+x[1-9][0-9]+$/ && $0 ~ /\*/){
		res= $1
		#print "current " output " res. is: " res
	}
	if ($1 == "640x480"){
		split(res, pix, /,/)
		if (pix[0]*pix[1] > maxres){
			maxres= pix[0]*pix[1]
			maxout=output
		}
	}
}
END {print output}')

[ "$main" != "$int_screen" ] && xrandr --output "$int_screen" --off
xrandr --output "$main" --primary
