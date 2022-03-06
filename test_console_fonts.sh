#!/bin/sh
# a simple script that changes the font of the virtual terminal until
# there's a font you like.
# Requires the print_all_ASCII.awk program to have a richer video feedback on
# the font appeareance.

cd /usr/share/kbd/consolefonts

for f in *; do
	if [ -r "$f" -a -f "$f" ]; then
		if [ -z "$(gzip -cd "$f" | file - | grep -i font)" ]; then
			echo "$f skipped (not a font)"
		else
			clear
			echo "font=$f"
			cd -
			./print_all_ASCII.awk
			cd -
			setfont "$f"
		fi
		# wait for <enter>
		read tmp
	fi
done 
