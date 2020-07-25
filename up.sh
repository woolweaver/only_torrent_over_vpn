#! /bin/bash

iptables-restore < rules

# Interface we want traffic to go to
export VPNIF="tun0"

# User for bit torrent client
export VPNUSER="qbit"

# regex filter for VPN gateway
GATEWAYIP=`ifconfig $VPNIF | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | egrep -v '255|(127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | tail -n1`

# How we can keep up with traffic of a certain user
export MARK="0x3"

if [[ `ip rule list | grep -c $MARK` == 0 ]]; then
ip rule add from all fwmark $MARK lookup $VPNUSER
fi

ip route replace default via $GATEWAYIP table $VPNUSER 

ip route append default via 127.0.0.1 dev lo table $VPNUSER

ip route flush cache
