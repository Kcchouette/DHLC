#!/bin/sh

echo "=== add contrib and non-free in sources.list (without deb-src) ==="
echo "deb http://ftp.$LANGUAGE.debian.org/debian $VERSION main contrib non-free" > ~/tmp.txt
echo "deb http://ftp.$LANGUAGE.debian.org/debian $VERSION-updates main contrib non-free" >> ~/tmp.txt
echo "deb http://security.debian.org/ $VERSION/updates main contrib non-free" >> ~/tmp.txt

echo < ~/tmp.txt >> /etc/apt/sources.list

echo "=== Wifi firmware installation ==="
apt-get update && apt-get install -y $DRIVERS_WIFI || return 0

echo "=== hostapd installation ==="
which hostapd || (apt-get install -y hostapd && insserv -r hostapd && service hostapd stop)


echo "=== DNS masq installation ==="
which dnsmasq || (apt-get install -y dnsmasq && insserv -r dnsmasq && service dnsmasq stop)


echo "=== DHCP server installation ==="
which dhcpd || (apt-get install -y isc-dhcp-server && insserv -r isc-dhcp-server && service isc-dhcp-server stop)

