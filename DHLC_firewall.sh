#!/bin/bash

echo "=== connexion from wifi to ethernet : hotspot ==="
bash -c "echo 1 > /proc/sys/net/ipv4/ip_forward" 
sleep 1

# load masquerade module
modprobe ipt_MASQUERADE
iptables -A POSTROUTING -t nat -o $INT_NET -j MASQUERADE

iptables -A FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT
iptables -A FORWARD -i $INT_WIFI --destination $SUBNET --match state --state NEW --jump ACCEPT
iptables -A INPUT -s $SUBNET --jump ACCEPT

