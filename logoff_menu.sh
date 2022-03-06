#!/bin/sh

actions='Annulla
Blocca schermo
Sospendi
Spegni
Riavvia'
prompt="Eh? Te ne vai?"

choice=$(echo "$actions" | rofi -lines $(echo "$actions" | wc -l) -dmenu -i -p "$prompt")

case "$choice" in
	Blocca\ schermo)
        commonopts="-i ~/Immagini/lockscreen.png"
		if [ -n "$SWAYSOCK" ]; then
			prg="swaylock $commonopts"
		else
			prg="i3lock -n $commonopts"
		fi
		;;
	Sospendi)
		prg='systemctl suspend'
		;;
	Spegni)
		prg=poweroff
		;;
	Riavvia)
		prg=reboot
		;;
	*)
		prg=true
		;;
esac
#echo "executing '$prg'"

exec $prg
