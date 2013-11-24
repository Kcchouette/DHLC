#!/bin/bash

echo -e $RED"!!! STOPPING !!!"$NC
echo "Stop hostapd, dhcpd, dnsmasq & interface wifi $INT_WIFI..."
# kill hostapd, dnsmasq & dhcpd
killall hostapd dnsmasq dhcpd
echo "END of all … please wait"
iptables -D POSTROUTING -t nat -o $INT_NET -j MASQUERADE 2>/dev/null
iptables -D FORWARD -i $INT_WIFI --destination $SUBNET --match state --state NEW --jump ACCEPT 2>/dev/null
iptables -D FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT 2>/dev/null
iptables -D INPUT -s $SUBNET --jump ACCEPT 2>/dev/null

echo "end of ipconfig"
ifconfig $INT_WIFI down
ifconfig $INT_WIFI up

echo "Turn off IP forwarding"
echo 0 > /proc/sys/net/ipv4/ip_forward
echo -e $RED"!!! DONE !!!"$NC



