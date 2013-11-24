#!/bin/sh

echo "=== hostapd configuration ==="
echo "interface=$INT_WIFI" > ~/tmp.txt
echo "driver=nl80211" >> ~/tmp.txt
echo "ssid=$NETWORK_NAME" >> ~/tmp.txt
echo "# wlan frequency channel (1-14)" >> ~/tmp.txt
echo "channel=$CHANNEL" >> ~/tmp.txt
echo "macaddr_acl=0" >> ~/tmp.txt
#echo "# mode Wi-Fi (a = IEEE 802.11a, b = IEEE 802.11b, g = IEEE 802.11g)" >> ~/tmp.txt
#echo "hw_mode=g" >> ~/tmp.txt
echo "# Authentification (or not) !" >> ~/tmp.txt
echo "auth_algs=1" >> ~/tmp.txt

if [ "$WPA_PASS" != "" ]; then
    echo "wpa=2" >> ~/tmp.txt
    echo "wpa_passphrase=$WPA_PASS" >> ~/tmp.txt
    echo "wpa_key_mgmt=WPA-PSK" >> ~/tmp.txt
    echo "wpa_pairwise=TKIP" >> ~/tmp.txt
    echo "rsn_pairwise=CCMP" >> ~/tmp.txt
    echo "ignore_broadcast_ssid=1" >> ~/tmp.txt
fi

cp -f ~/tmp.txt ./DHLCconf/hostapd.conf

echo "=== Wlan interface configuration ==="
ifconfig $INT_WIFI down
sleep 0.5
ifconfig $INT_WIFI $IP netmask $MASK up


echo "=== DHCP configuration ==="
echo "# Sample /etc/dhcpd.conf" > ~/tmp.txt
echo "default-lease-time 600;" >> ~/tmp.txt
echo "max-lease-time 7200;" >> ~/tmp.txt
echo "authoritative;" >> ~/tmp.txt
echo "log-facility local7;" >> ~/tmp.txt
echo "option domain-name-servers $IP;" >> ~/tmp.txt
# echo "option ntp-servers 192.168.1.254;" >> ~/tmp.txt
echo "subnet 192.168.$SUB.0 netmask $MASK {" >> ~/tmp.txt
echo "#option domain-name 'wifi.localhost';" >> ~/tmp.txt
echo "option routers $IP;" >> ~/tmp.txt
echo "option subnet-mask $MASK;" >> ~/tmp.txt
echo "option broadcast-address 192.168.$SUB.0;" >> ~/tmp.txt
echo "option domain-name-servers $IP;" >> ~/tmp.txt
echo "range dynamic-bootp 192.168.$SUB.15 192.168.$SUB.100;" >> ~/tmp.txt
echo "}" >> ~/tmp.txt

cp -f ~/tmp.txt ./DHLCconf/dhcpd.conf


echo "=== DNS masq configuration ==="
echo "bogus-priv" > ~/tmp.txt
echo "filterwin2k" >> ~/tmp.txt
echo "# no-resolv" >> ~/tmp.txt
echo "interface=$INT_WIFI" > ~/tmp.txt
echo "no-dhcp-interface=$INT_WIFI" >> ~/tmp.txt

cp -f ~/tmp.txt ./DHLCconf/dnsmasq.conf
