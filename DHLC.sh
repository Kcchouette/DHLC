#!/bin/bash

# Copyright © Kcchouette on Github.com
# DHLC is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# DHLC is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
#See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with DHLC.  If not, see <http://www.gnu.org/licenses/>. 

# Thanks to ubuntu-fr, debian and hostapd documentation to help me to do this software

#Some colors
RED='\e[1;31m'
NC='\e[0m' #No Color

#Debian configuration
VERSION="wheezy"
DRIVERS_WIFI="zd1211-firmware"
LANGUAGE="fr";

#interface configuration 
INT_WIFI="wlan0" # wifi interface (which share the wifi)
INT_NET="eth0" # wlan or eth0 interface (computer receive Internet with that)

#IP and Mask for the wifi subnetwork
SUBNET="192.168.0.0/24" 
IP="192.168.0.1"
MASK="255.255.255.0"
#GW="$IP"

#Name of the wifi network
NOM_RESEAU="DHLC network"

echo "=== keyboard in your language ==="
setxkbmap $LANGUAGE || loadkeys $LANGUAGE

echo "=== add contrib and non-free in sources.list (without deb-src) ==="
echo "deb http://ftp.$LANGUAGE.debian.org/debian $VERSION main contrib non-free" > ~/tmp.txt
echo "deb http://ftp.$LANGUAGE.debian.org/debian $VERSION-updates main contrib non-free" >> ~/tmp.txt
echo "deb http://security.debian.org/ $VERSION/updates main contrib non-free" >> ~/tmp.txt

sudo cp -f ~/tmp.txt /etc/apt/sources.list

echo "=== Wifi firmware installation ==="
sudo apt-get update && sudo apt-get install -y $DRIVERS_WIFI

echo "=== hostapd installation ==="
sudo apt-get install -y hostapd

echo "=== hostapd configuration ==="
echo "interface=$INT_WIFI" > ~/tmp.txt
echo "driver=nl80211" >> ~/tmp.txt
echo "ssid=$NETWORK_NAME" >> ~/tmp.txt
echo "# wlan frequency channel (1-14)" >> ~/tmp.txt
echo "channel=6" >> ~/tmp.txt
#echo "# mode Wi-Fi (a = IEEE 802.11a, b = IEEE 802.11b, g = IEEE 802.11g)" >> ~/tmp.txt
#echo "hw_mode=g" >> ~/tmp.txt
echo "# Open Wlan : no authentification !" >> ~/tmp.txt
echo "auth_algs=1" >> ~/tmp.txt

sudo cp -f ~/tmp.txt /etc/hostapd/hostapd.conf

echo "=== Wlan interface configuration ==="
sudo ifconfig $INT_WIFI down
sleep 0.5
sudo ifconfig $INT_WIFI $IP netmask $MASK up

echo "=== DHCP server installation ==="
sudo apt-get install -y isc-dhcp-server

echo "=== DHCP configuration ==="
echo "# Sample /etc/dhcpd.conf" > ~/tmp.txt
echo "# (add your comments here) " >> ~/tmp.txt
echo "default-lease-time 600;" >> ~/tmp.txt
echo "max-lease-time 7200;" >> ~/tmp.txt
echo "authoritative;" >> ~/tmp.txt
echo "log-facility local7;" >> ~/tmp.txt
echo "option domain-name-servers $IP;" >> ~/tmp.txt
echo "option ntp-servers 192.168.1.254;" >> ~/tmp.txt
echo "subnet 192.168.0.0 netmask $MASK {" >> ~/tmp.txt
echo "#option domain-name 'wifi.localhost';" >> ~/tmp.txt
echo "option routers $IP;" >> ~/tmp.txt
echo "option subnet-mask $MASK;" >> ~/tmp.txt
echo "option broadcast-address 192.168.0.0;" >> ~/tmp.txt
echo "option domain-name-servers $IP;" >> ~/tmp.txt
echo "range dynamic-bootp 192.168.0.15 192.168.0.100;" >> ~/tmp.txt
echo "}" >> ~/tmp.txt

sudo cp -f ~/tmp.txt /etc/dhcp/dhcpd.conf

echo "=== DNS masq installation ==="
sudo apt-get install -y dnsmasq

echo "=== DNS masq configuration ==="
echo "bogus-priv" > ~/tmp.txt
echo "filterwin2k" >> ~/tmp.txt
echo "# no-resolv" >> ~/tmp.txt
echo "interface=$INT_WIFI" > ~/tmp.txt
echo "no-dhcp-interface=$INT_WIFI" >> ~/tmp.txt

sudo cp -f ~/tmp.txt /etc/dnsmasq.conf

echo "=== connexion from wifi to ethernet : hotspot ==="
sudo bash -c "echo 1 > /proc/sys/net/ipv4/ip_forward" 
sleep 1

echo "=== hostapd launch ==="
sudo hostapd /etc/hostapd/hostapd.conf &
sleep 1

echo "=== DNS masq launch ==="
sudo dnsmasq -x /var/run/dnsmasq.pid -C /etc/dnsmasq.conf &
sleep 1

echo "=== DHCP launch ==="
# start or restart dhcpd server (see /etc/dhcpd/dhcpd.conf)
sudo touch /var/lib/dhcp/dhcpd.leases
#sudo mkdir -p /var/run/dhcp-server
#sudo chown dhcpd:dhcpd /var/run/dhcp-server
sudo dhcpd $DBG -f -pf /var/run/dhcp-server/dhcpd.pid -cf /etc/dhcp/dhcpd.conf $INT_WIFI &
#/etc/init.d/dhcp-server restart
sleep 1

# load masquerade module
sudo modprobe ipt_MASQUERADE
sudo iptables -A POSTROUTING -t nat -o $INT_NET -j MASQUERADE

sudo iptables -A FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT
sudo iptables -A FORWARD -i $INT_WIFI --destination $SUBNET --match state --state NEW --jump ACCEPT
sudo iptables -A INPUT -s $SUBNET --jump ACCEPT

echo -e $RED"STOP it ? enter Y to stop it"$NC
read commande

if [ $commande = "Y" ]
	then 
	echo "Stop hostapd, dhcpd, dnsmasq & interface wifi $INT_WIFI..."
	# kill hostapd, dnsmasq & dhcpd
	sudo killall hostapd dnsmasq dhcpd
	echo "END of all … please wait"
	sudo iptables -D POSTROUTING -t nat -o $INT_NET -j MASQUERADE 2>/dev/null
	sudo iptables -D FORWARD -i $INT_WIFI --destination $SUBNET --match state --state NEW --jump ACCEPT 2>/dev/null
	sudo iptables -D FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT 2>/dev/null
	sudo iptables -D INPUT -s $SUBNET --jump ACCEPT 2>/dev/null
 
	echo "end of ipconfig"
	sudo ifconfig $INT_WIFI down
	sudo ifconfig $INT_WIFI up
 
	echo "Turn off IP forwarding"
	echo 0 > /proc/sys/net/ipv4/ip_forward
	echo -e $RED"!!! DONE !!!"$NC
	exit 0
fi

