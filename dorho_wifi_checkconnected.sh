#!/bin/bash

reply="$(echo -en "GET / HTTP/1.0\r\nHost: 1.1.1.1\r\n\r\n"|netcat 1.1.1.1 80|dos2unix)"

if [ -n "$(echo "$reply"|head -n -1| grep -E '^HTTP/1.1 302 Moved Temporarily$')" \
	-a -n "$(echo "$reply"|grep -E '^Location: http://172.16.0.1')" ]; then
	echo not connected
else
	echo connected
fi

