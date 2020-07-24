# Force User To Use Specific Network Interface

Make all network traffic for a specific user use a specific network interface.

# Needed things:

* iptables-persistent netfilter-persistent

* VPN server/service

I found this here --> https://www.niftiestsoftware.com/2011/08/28/making-all-network-traffic-for-a-linux-user-use-a-specific-network-interface <-- by accedent and worked very nicely for me so I saved it here to find easier next time.

I’ve recently been testing out a VPN service, and normally while running the VPN, all internet traffic goes over the VPN interface. This isn’t really ideal, as I only want traffic from a specific application ([qBittorrent](https://www.qbittorrent.org/)) to use the VPN. IPTables doesn’t seem to have the option to filter specific processes, but it can filter based on a specific user.

IPTables itself doesn’t really deal with routing packets to interfaces, so we can’t use it to directly route packets. 

We can however mark packets from the user so they can be routed by the ip routing table. 

Here is a script to flush and apply the firewall rules that we need (obviously change the variables at the beginning of the script to match your needs):

 * see [tables.sh](tables.sh)

Now all traffic from the specified user will be marked for the VPN. We also need to add a routing table, by adding the table name to the rt_tables file. 

On Rapbian this file is in `/etc/iproute2/rt_tables` and appears as follows:

```
#
# reserved values
#
255     local
254     main
253     default
0       unspec
#
# local
#
#1      inr.ruhep
200     vpnuser # This is the one we added
```

Next we need a script to configure the routing rules for the marked packets:

* see [up.sh](up.sh)

If you are using OpenVPN, you will need to ensure this line is in your config file to prevent all traffic from being sent over the VPN:

```
route-nopull
```

You may also need to add these lines into /etc/sysctl.d/9999-vpn.conf to ensure the kernel lets the traffic get routed correctly (this disables reverse path filtering):

```
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.br0.rp_filter = 0
```

Then run:

`sysctl -p`

To apply the new sysctl rules. You may also need to restart your VPN if you are already connected.

Now run the two scripts ( the second script (up.sh) needs to run when the network interface starts – this is in /etc/conf.d/net on Gentoo, or the ‘up’ command in OpenVPN’s config file ) , and the specific user should only be able to access traffic on the VPN, and other users on the system should access the network as normal.