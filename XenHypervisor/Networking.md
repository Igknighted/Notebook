Securing the network is a no-brainer. We will want to prevent virtual machines from snooping or stealing IP's. 

Currently I am reading these docs:
http://wiki.xenproject.org/wiki/Network_Configuration_Examples_(Xen_4.1%2B)
http://wiki.xenproject.org/wiki/Xen_FAQ_Networking

... adding more here later.

Initial thoughts:
It looks like ghetto bridging was done with some script magic to prevent arp poisoning in the old days. It looks like I may need to use openvswitch, create a virtual interface for each virtual machine, restrict IP assignments by an assigned MAC address with DHCP, and from within openvswitch route out through eth0.... maybe. 
