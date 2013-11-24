#!/bin/sh

#Some colors
RED="$(tput setaf 1)"
NC="$(tput sgr0)" #No Color

#Debian configuration
VERSION="wheezy"
DRIVERS_WIFI="zd1211-firmware"
LANGUAGE="fr";

#interface configuration 
INT_WIFI="wlan0" # wifi interface (which share the wifi)
INT_NET="eth0" # wlan or eth0 interface (computer receive Internet with that)

#IP and Mask for the wifi subnetwork
SUB="0"
SUBNET="192.168.$SUB.0/24" 
IP="192.168.$SUB.1"
MASK="255.255.255.0"
#GW="$IP"

#Name of the wifi network
NETWORK_NAME="DHLC network"
#if WPA_PASS="", there is no authentification
WPA_PASS="testtest"
CHANNEL=10
