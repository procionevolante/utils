#!/bin/sh
# start sway WM with the correct environment
# see https://wiki.archlinux.org/index.php/Sway

# also see https://wiki.archlinux.org/index.php/Wayland#GUI_libraries

unset DISPLAY
# can be set more cleanly in config file
#export XKB_DEFAULT_OPTIONS="caps:super"
#export XKB_DEFAULT_LAYOUT="it"

# GTK 3.0+
export GDK_BACKEND=wayland
export CLUTTER_BACKEND=wayland
# Qt5
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
# SDL
export SDL_VIDEODRIVER=wayland
# Java AWT
export _JAVA_AWT_WM_NONREPARENTING=1
# XDG variable(s)
export XDG_CURRENT_DESKTOP=sway

# additional exports
#export WLC_XWAYLAND=0

# run blue light controller
# NOTE: not needed if you have redshift's fork, gammastep
# that works natively on wayland
#if [ "$(hostname)" != spesafantastica ]; then
#	redshift -orm drm
#fi

exec sway "$@"
