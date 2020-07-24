# Force User To Use Specific Network Interface

Make all network traffic for a specific user (or in my case [qBittorrent](https://www.qbittorrent.org/)) to use a specific network interface (a VPN).

_______
 * Needed things:
 
   1. iptables-persistent 
   2. netfilter-persistent
   3. VPN server/service
_______
   
As we all know normally when connected to a VPN all internet traffic goes over the VPN interface, but I only want traffic from [qBittorrent](https://www.qbittorrent.org/) to use the VPN. 

IPTables doesn’t have the option to filter specific processes, but it can filter based on a specific user (or application if it is started by the user in question).

IPTables doesn’t deal with routing packets to interfaces, so we can’t use it to route packets however we can mark packets from the user we specify so they can be routed by the ip routing table. 

The following script will **flush all existing** firewall rules (Please save them if they are important) and apply the firewall rules that we need (obviously change the variables at the beginning of the script to match your needs):

 * see [tables.sh](tables.sh)

Now all traffic from the specified user will be marked for the VPN. Now we need to add a routing table, by adding the table name to the rt_tables file. 

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

You may also need to add these lines into `/etc/sysctl.d/9999-vpn.conf` to ensure the kernel lets the traffic get routed correctly (this disables reverse path filtering):

```
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.br0.rp_filter = 0
```

Then run `sysctl -p` to apply the new sysctl rules. You may also need to restart your VPN if you are already connected.

Now run the two scripts (the second script ([up.sh](up.sh)) needs to run when the VPN connects succesfully – this is in /etc/conf.d/net on Gentoo, or the ‘up’ command in OpenVPN’s config file ) , and the specific user should only be able to access traffic on the VPN, and other users on the system should access the network as normal.







 * [credit](https://www.niftiestsoftware.com/2011/08/28/making-all-network-traffic-for-a-linux-user-use-a-specific-network-interface)
