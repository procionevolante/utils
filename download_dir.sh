#!/bin/bash
if [ $# -eq 0 -o "$1" = "-h" -o "$1" = "--help" ]; then
	cat <<- EOF
	USAGE: $0 [remote_dir]...
	example: $0 "http://fmgroup.polito.it/quer/teaching/so/laib/testi/"

	Download all the content linked in a page, recursively
	It is designed to download all files from those sites that let you visualize
	a directory tree trough an ugly but light HTML page

	note: you may want to try using lftp's mirror command instead
	EOF
	exit 1
fi

for url in "$@"; do
	# format the URL how we like it
	[ $(echo "$url" |grep -E '.+/$'|wc -l) -ne 1 ] && url=$url/
	[ $(echo "$url" |grep "://"|wc -l) -ne 1 ] && url=http://$url
	# download the stuff
	wget -r -R "index.html*" -R "robots.txt*" -np -nH --cut-dirs=$((`echo "$url"|tr -dc /|wc -c`-3)) "$url"
done
rm -f robots.txt.tmp
