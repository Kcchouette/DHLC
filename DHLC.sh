#!/bin/sh

# Copyright © Kcchouette on Github.com
# DHLC is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# DHLC is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
#See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with DHLC.  If not, see <http://www.gnu.org/licenses/>. 

# Thanks to ubuntu-fr, debian and hostapd documentation to help me to do this software

set -e

if [ "$(id -u)" != "0" ]; then
    echo "you must be root"
    exit 0
fi

. ./DHLC_conf.sh

echo "=== keyboard in your language ==="
setxkbmap $LANGUAGE || loadkeys $LANGUAGE

if [ "$1" = 'stop' ]; then
    . ./DHLC_stop.sh
    exit 0
fi
if [ "$1" = 'install' ]; then
    . ./DHLC_install.sh
    exit 0
fi

mkdir -p ./DHLCconf || exit 1

if [ "$1" != 'start' ]; then
    echo "$0 install/start/stop"
    exit 1
fi

. ./DHLC_gen.sh
. ./DHLC_run.sh
. ./DHLC_firewall.sh

echo -e $RED"!!! START !!!"$NC


