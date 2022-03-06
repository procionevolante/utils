#!/bin/bash
# notice that this actually doesn't work because /dev/rfkill can't be accessed
# as a normal user
if [ "`rfkill -no SOFT`" = "unblocked" ]; then
	rfkill block all
	notify-send  -i airplane-mode-symbolic "WiFi OFF"
else
	rfkill unblock all
	notify-send  -i network-wireless-signal-excellent-symbolic "WiFi ON"
fi
