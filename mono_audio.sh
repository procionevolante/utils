#!/bin/sh
# from https://superuser.com/questions/657876/mono-sound-output-in-ubuntu

# after the execution, a new output becomes available in the mixer
if [ -z "$(pacmd list-modules | grep name: | grep module-remap-sink)" ]; then
	# module not loaded, reload it
	exec pacmd load-module module-remap-sink sink_name=mono master=@DEFAULT_SINK@ channels=2 channel_map=mono,mono
else
	# module loaded, unload it
	exec pacmd unload-module module-remap-sink
fi
