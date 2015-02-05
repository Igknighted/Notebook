```
# cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
	address 192.168.0.16
	gateway 192.168.0.1
	netmask 255.255.255.0
	dns-nameservers 8.8.8.8 8.8.4.4
```
