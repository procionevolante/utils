#!/bin/sh
# Enables a remote client to play audio on this pc by using it as pulseaudio server.
module_name='module-native-protocol-tcp'
module_param='auth-anonymous=true'

set -e

if [ -z "$(env LANG='' LC_ALL='' pactl list modules | fgrep "Name: $module_name")" ]; then
	pactl load-module "$module_name" $module_param> /dev/null
	cat <<- EOF
		module loaded.
		Set env variable PULSE_SERVER=my_IP_address to connect to it.
		Run this program again to unload the module.
		EOF
else
	pactl unload-module "$module_name"
	echo "module unloaded"
fi
