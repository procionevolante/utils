#!/bin/sh

# shares the connection from an interface to another enabling NAT, forwarding,..
# basically, it creates a wifi from an ethernet connection

eth_iface=enp4s0
wlan_iface=wlp1s0
wlan_con_name='eth2wifi'
wlan_ssid='garlic bread'
wlan_pwd='magic hoodie'

if ! nmcli connection show "$wlan_con_name"  > /dev/null 2>&1; then
	echo creating the connection...
	nmcli connection add con-name "$wlan_con_name" autoconnect no \
		ifname "$wlan_iface" \
		type wifi \
		connection.zone trusted \
		connection.autoconnect-retries 2 \
		connection.auth-retries 2 \
		802-11-wireless.mode ap \
		802-11-wireless.ssid "$wlan_ssid" \
		802-11-wireless-security.key-mgmt wpa-psk \
		802-11-wireless-security.psk "$wlan_pwd" \
		802-11-wireless-security.proto rsn \
		802-11-wireless-security.pairwise ccmp \
		ipv4.method shared \
		ipv6.method ignore
fi

# toggle the connection on/off

if [ "$(nmcli device show "$wlan_iface" | grep -E '^GENERAL\.CONNECTION' |
	tr -s ' ' | cut -d ' ' -f 2-)" = "$wlan_con_name" ]; then
	echo turning off hotspot...
	nmcli connection down "$wlan_con_name"
else
	echo turning on hotspot
	nmcli connection up "$wlan_con_name"
fi
