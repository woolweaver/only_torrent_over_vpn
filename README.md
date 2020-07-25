# only torrent over vpn

only torrent over vpn

_______
 * Needed things:
 
   1. iptables-persistent 
   2. netfilter-persistent
   3. VPN server/service
_______
   
As we all know normally when connected to a VPN all internet traffic goes over the VPN, but I only want traffic from [qBittorrent](https://www.qbittorrent.org/) to use the VPN. 

IPTables can't filter for a specific application, but it can filter for a specific user. On Linux (and maybe other OSes) you can start an application/program as a specific user.

## Step One: Create user to run torrent client as

 * `useradd -m qbit`
 
 * we will also disable this accounts ability to login
 
 * `usermod -L qbit`
 
 ## Step Two: Configure Firewall & Routing Rules

IPTables doesn’t deal with routing but it will allow us to mark traffic from the user we specify so that it can be routed by the ip routing table after we setup some firewall rules. 

### Two(dot)One: Firewall Config

Use the following script to apply the needed firewall rules (change the variables to what you need):

 * see [tables.sh](https://raw.githubusercontent.com/mwoolweaver/only_torrent_over_vpn/master/tables.sh)

Now all traffic from the specified user will be marked with `0x3`. 

### Two(dot)Two: Routing Table Config

Now we need to add our table name to `/etc/iproute2/rt_tables` so that traffic will go to the right interface. 

On Raspbian is appears as follows:

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
200     qbit # This is the one we added
```

Now we need to configure the routing rules for the table we just added       
*Basically it will be looking for traffic marked with `0x3`*

* see [up.sh](https://raw.githubusercontent.com/mwoolweaver/only_torrent_over_vpn/master/up.sh)

## Step Three: VPN Client config

If you are using OpenVPN, you will need to ensure this line is in your config file to prevent all traffic from being sent over the VPN:

```
route-nopull
```

You may also need to add these lines into `/etc/sysctl.d/9999-vpn.conf` to ensure the kernel lets the traffic get routed correctly      
*this will disable [reverse path filtering](https://www.tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.kernel.rpf.html)*
```
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.br0.rp_filter = 0
```
Now you need to run `sysctl -p` to apply the new sysctl rules. 

You may also need to restart your VPN if you are already connected.



Now run the two scripts.

The (**qbit**) user should be the only user be able to access the VPN, and other users on the system should access the network as normal.

Test this 








 * [credit](https://www.niftiestsoftware.com/2011/08/28/making-all-network-traffic-for-a-linux-user-use-a-specific-network-interface)
