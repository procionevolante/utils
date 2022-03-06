#!/bin/bash
#	backup of directory BACKUPS on server

source secrets
#	NOTE:	put directories without the ending "/"
declare locale="${backup_locale_dir}"
declare remote="${backup_remote_dir}"
declare pass_file
#declare opts=`getopt -n $0 -o hc -l help,complete -- $@`

set -e

if [ $# -gt 2 -o "$1" = "-h" -o "$1" = "--help" ]; then
	echo options:
	echo -e "-h --help\tprint this text and exit"
	echo -e "-c --complete\tsyncronize completely with this machine\n\t(delete files on server that doesn't exist here)"
	echo the default behaviour is to upload modifications and then download new files added to the server
	exit
fi

pass_file=`mktemp --tmpdir`
echo -e "backup of\n $locale\n\t<<< >>>\n $remote\n\n"
read -s -p "insert password for \"$remote\": " pass
echo "$pass" > "$pass_file"
unset pass

if [ "$1" = "-c" -o "$1" = "--complete" ]; then
	echo -e "\nlist of files that WILL be deleted:"
	sleep 3
	rsync --dry-run --info=DEL --password-file "$pass_file" --delete -urOt "$locale"/ "$remote" |cut -d ' ' -f 2-
	echo -e "\nWARNING: these files will be DELETED from the server! continue? [y/N]"
	read ans
	if [ "$ans" = y -o "$ans" = yes ]; then
		rsync --password-file "$pass_file" --delete --delete-delay -vurOt "$locale"/ "$remote"
	else
		echo aborting...
	fi
else
	echo -e "\n\tLOCALHOST-SERVER SYNC\n"
	#	NOTE: -t is used to preserve modification timestamps
	#	NOTE:	-o doesn't use -t for directories (if not used, timestamps are updated for directories everytime)
	#	if --size-only isn't used on the second sync for some reason the download may include all files present on the server
	#	NOTE: -F skyps files that match the filters specified in .rsync-filter
	rsync --password-file "$pass_file" -vurOtF --modify-window=1 "$locale"/ "$remote"

	echo -e "\n\tSERVER-LOCALHOST SYNC\n"
	#rsync --password-file "$pass_file" -vurOtF --modify-window=1 --size-only "$remote"/ "$locale"
	rsync --password-file "$pass_file" -vurOtF --modify-window=1 "$remote"/ "$locale"
fi

rm $pass_file
