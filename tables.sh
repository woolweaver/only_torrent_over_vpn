#! /bin/bash

export INTERFACE="tun0"
export NETIF="br0"

export VPNUSER="qbit"

export LANIP="10.0.0.0/24"

export MARK="0x3"

export DNS1="1.1.1.1"
export DNS2="1.0.0.1"

iptables -F -t nat
iptables -F -t mangle
iptables -F -t filter

# mark packets from $VPNUSER
iptables -t mangle -A OUTPUT ! --dest $LANIP  -m owner --uid-owner $VPNUSER -j MARK --set-mark $MARK
iptables -t mangle -A OUTPUT --dest $LANIP -p udp --dport 53 -m owner --uid-owner $VPNUSER -j MARK --set-mark $MARK
iptables -t mangle -A OUTPUT --dest $LANIP -p tcp --dport 53 -m owner --uid-owner $VPNUSER -j MARK --set-mark $MARK
iptables -t mangle -A OUTPUT ! --src $LANIP -j MARK --set-mark $MARK

# allow responses
iptables -A INPUT -i $INTERFACE -m conntrack --ctstate ESTABLISHED -j ACCEPT

# allow bittorrent
iptables -A INPUT -i $INTERFACE -p tcp --dport 59560 -j ACCEPT
iptables -A INPUT -i $INTERFACE -p tcp --dport 6443 -j ACCEPT

iptables -A INPUT -i $INTERFACE -p udp --dport 8881 -j ACCEPT
iptables -A INPUT -i $INTERFACE -p udp --dport 7881 -j ACCEPT

# block everything incoming on $INTERFACE
iptables -A INPUT -i $INTERFACE -j REJECT

# send DNS to google for $VPNUSER
iptables -t nat -A OUTPUT --dest $LANIP -p udp --dport 53  -m owner --uid-owner $VPNUSER  -j DNAT --to-destination $DNS1
iptables -t nat -A OUTPUT --dest $LANIP -p tcp --dport 53  -m owner --uid-owner $VPNUSER  -j DNAT --to-destination $DNS2

# let $VPNUSER access lo and $INTERFACE
iptables -A OUTPUT -o lo -m owner --uid-owner $VPNUSER -j ACCEPT
iptables -A OUTPUT -o $INTERFACE -m owner --uid-owner $VPNUSER -j ACCEPT

# all packets on $INTERFACE needs to be masqueraded
iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE

# reject connections from predator ip going over $NETIF
iptables -A OUTPUT ! --src $LANIP -o $NETIF -j REJECT
