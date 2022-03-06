#!/bin/bash
# screenshot utility for wayland/sway
# dependencies:
# * slurp (to select the screen region)
# * grim (to actually memorize the screenshot)
# * zenity (for file save menu)
# * wofi || rofi (to select other things)
# * wl-clipboard (to copy image in the clipboard)

# Multiple Choice Question
mcq() {
    local title="$1"
    local input="$2"
    shift 2
    for choice in "$@"; do
        input="$(printf '%s\n%s' "${input}" "$choice")"
    done
    #choice="$(echo -e '1. entire screen\n2. screen portion' | rofi -lines 2 -dmenu | cut -c 1)"
    #zone="$(zenity --list --text 'what zone of the screen do you want to capture?' \
    #	--hide-header --radiolist --column 'radio' --column 'screen' 1 area 2 all)"
    echo -n "$input "| wofi -S dmenu -p "$prompt"
    # wofi returns 1 if no choice is made
    return $?
}

save_file() {
    local b64_data="$1"
    local filename_template="${2:-Screenshot.png}"
    local fout="$(zenity --file-selection --title 'Select the destination file'\
        --save --confirm-overwrite --file-filter 'PNG|*.png|*.PNG'\
        --file-filter 'JPG|*.jpg|*.JPG|*.jpeg|*.JPEG'\
        --filename "$filename_template" | head -n 1)"
    [ $? -ne 0 ] && return 1
    if echo "$fout" | grep -qE '(jpe?g|JPE?G)$'; then
        echo saving as jpeg
        echo "$b64_data" | base64 -d | convert - "$fout" || return 1
    else
        echo saving as png
        echo "$b64_data" | base64 -d > "$fout" || return 1
    fi
}

save_clipboard() {
    local b64_data="$1"
    echo "$b64_data" | base64 -d | wl-copy || return 1
}
    
zone="$(mcq 'Screenshot' 'whole screen' 'square area')"
[ $? -ne 0 ] && exit 0

echo "capture zone is '${zone}'"

# image capture
if [[ "$zone" =~ whole ]]; then
    img="$(grim -t png - | base64)"
elif [[ "$zone" =~ square ]]; then
	notify-send 'select screen region'
	region="$(slurp)"
    img="$(grim -t png -g "$region" - | base64)"
else
    echo should not be here. "zone='$zone'"
fi

saveto="$(mcq 'Store image in...' 'file' 'clipboard')"
[ $? -ne 0 ] && exit 0

if [ "$saveto" = file ]; then
    if save_file "$img" "capture_$(date '+%Y-%m-%d_%T').png"; then
        notify-send "image saved"
    else
        notify-send 'error while saving the image. We apologize for the inconvinience'
    fi
elif [ "$saveto" = clipboard ]; then
    if ! save_clipboard "$img"; then
        notify-send 'done!'
    else
        notify-send 'error!'
    fi
fi
