#!/bin/sh
# a stupid script to run a program in X.org even when environment variables
# say otherwise. Useful when working in wayland.
exec env CLUTTER_BACKEND=x11 \
	QT_QPA_PLATFORM=xcb \
	SDL_VIDEODRIVER=x11 \
	GDK_BACKEND=x11 \
	"$@"
