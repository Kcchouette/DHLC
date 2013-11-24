#!/bin/bash

echo "=== hostapd launch ==="
setsid hostapd ./DHLCconf/hostapd.conf &
sleep 1

echo "=== DNS masq launch ==="
setsid dnsmasq -C ./DHLCconf/dnsmasq.conf &
sleep 1

echo "=== DHCP launch ==="
# start or restart dhcpd server (see /etc/dhcpd/dhcpd.conf)
touch /var/lib/dhcp/dhcpd.leases
#mkdir -p /var/run/dhcp-server
#chown dhcpd:dhcpd /var/run/dhcp-server
setsid dhcpd $DBG -f -pf ./DHLCconf/dhcpd.pid -cf ./DHLCconf/dhcpd.conf $INT_WIFI &
#/etc/init.d/dhcp-server restart
sleep 1
