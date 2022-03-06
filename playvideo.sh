#!/bin/bash
declare info_file
declare video_file
declare screen_w
declare screen_h
declare width
declare height
declare s_ratio
declare v_ratio

if	[ $# -eq 0 -o "$1" == "--help" ]; then
	cat <<- EOF
	$0: a really cool script that prevents getting old while writing parameters to watch videos on framebuffer using mplayer
	USAGE: $0 VIDEO_FILE [additional mplayer parameters]
	IT REQUIRES:
	 - mplayer (you don't say...)
	 - fbset
	 - bc
	 - awk
	you can also use the env variable FBDEV to force the use of a specific framebuffer file (ex '/dev/fb0')
	EOF
	exit 0
fi

#checking if the required programs are present
if [ -z "`mplayer`" -o -z "`awk -V`" -o -z "`bc -v`" -o -z "`fbset -V`" ]; then
	echo some programs may not be installed. aborting
	echo require: mplayer, awk, bc, fbset
	exit 1
fi

#getting the video file name among all the parameters
for video_file in "$*"; do
	[ -r "$video_file" ] && break;
done

info_file=`mktemp --tmpdir`
#reading the screen resolution
[ -z "$FBDEV" ] && FBDEV="/dev/fb0"
fbset -fb "$FBDEV" --show |grep geometry > "$info_file"
screen_w=`cat "$info_file" |awk -F " " '{ print $2 }'`
screen_h=`cat "$info_file" |awk -F " " '{ print $3 }'`
#screen_w=`cat "$info_file" |cut -d ' ' -f 6`
#screen_h=`cat "$info_file" |cut -d ' ' -f 7`

#barbar method to clear the screen and bring the pointer to the bottom of the screen
clear
for i in `seq 1 $LINES`; do
	echo
done

echo gathering infos of $video_file...
mplayer -vo null -ao null -identify -frames 0 "$video_file" > "$info_file"
#width=`grep ID_VIDEO_WIDTH "$info_file" |cut -d '=' -f 2`
#height=`grep ID_VIDEO_HEIGHT "$info_file" |cut -d '=' -f 2`
width=`grep ID_VIDEO_WIDTH "$info_file"| awk -F "=" '{ print $2}'`
height=`grep ID_VIDEO_HEIGHT "$info_file"| awk -F "=" '{ print $2}'`
rm "$info_file"
s_ratio=`echo "$screen_w / $screen_h"|bc -l`
v_ratio=`echo "$width / $height"|bc -l`

echo pc screen has resolution: "$screen_w"x"$screen_h" ratio= $s_ratio
echo video file has resolution: "$width"x"$height" ratio= $v_ratio

#deciding whether to maintain screen height or width
#and scale the other for optimal zoom
#or just use native resolution of screen
#the cosinus here is used as a sort of absolute value
if [ `echo "c($s_ratio-$v_ratio)>.999 "|bc -l` -ne 0 ]; then
	#in this case, ratio is considered equal
	height=$screen_h
	width=$screen_w
elif [ `echo "$s_ratio < $v_ratio"|bc` -ne 0 ]; then
	#height calculation
	height=`echo "$screen_w * (1/ $v_ratio )"|bc -l`
	width=$screen_w

	#rounding
	height=`echo $height | awk '{print int($1+0.5)}'`
	[ $height -gt $screen_h ] && height=$screen_h
else
	#width calculation
	width=`echo "$screen_h * $v_ratio"|bc -l`
	height=$screen_h

	#rounding
	width=`echo $width | awk '{print int($1+0.5)}'`
	[ $width -gt $screen_w ] && width=$screen_w
fi

echo "remember that now you can use directly mpv with --vo drm"
echo playing video with resolution: "$width"x"$height"

for i in `seq 2 -1 1`; do
	echo -en "\rin $i seconds"
	sleep 1
done

exec mplayer -fs -vo fbdev2:"$FBDEV" -screenh $screen_h -screenw $screen_w -x $width -y $height -zoom "$@"
