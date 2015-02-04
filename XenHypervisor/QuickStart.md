This is a quick start to get a CentOS 7 VM setup in a Xen hypervisor on Ubuntu. Most of the information was consumed from https://help.ubuntu.com/community/Xen

First setup Ubuntu Server (no GUI). On the first run, we need to setup the hypervisor and the bridged network adapter. Install the things! The xen hypervisor will be automatically set to be the first kernel in grub.
```
# apt-get install xen-hypervisor-amd64 bridge-utils
```

Setup the bridged network adapter and make sure you don't use stupid things like network-manager.
```
# update-rc.d network-manager disable
# /etc/init.d/network-manager stop
# vim /etc/network/interfaces
# cat /etc/network/interfaces
auto lo
iface lo inet loopback

auto xenbr0
iface xenbr0 inet dhcp
    bridge_ports eth0

auto eth0
iface eth0 inet manual
```

Reboot the server now and when it comes back up check to make sure things were done right.
```
# reboot
... server reboots
# xl list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0   945     1     r-----      11.3
# ifconfig
... make sure it has your network interfaces!
# ping google.com
... we should have internet... gosh
```

Now we can move on to creating an actual VM. I expect that we put aside LVM space. We will setup a logical volume. If you are not familiar with LVM yet, I recommend going back to class and picking that up before proceeding (hint: know what physical volumes, volume groups, and logical volumes are).

Now, create the logical volume. I have space in the mini-vg volume group. My virtual machine is going to be named "thor" so I'm naming my logical volume thor to match.
```
# lvcreate -L 10G -n thor /dev/mini-vg
```

Now I need to get a copy of CentOS minimal to install. There are a few ways to do this, I personally prefer doing it over VNC with some point and click GUI.
```
# mkdir -p /var/lib/xen/images/
# wget <MIRROR_URL>/centos/7/isos/x86_64/CentOS-7.0-1406-x86_64-Minimal.iso
# mv CentOS-7.0-1406-x86_64-Minimal.iso centos7-minimal.iso
```

Now to make a config file. For sanity sake, I keep my VM configs in /etc/xen/vms
```
# mkdir /etc/xen/vms
# vim /etc/xen/vms/thor.cfg
# vim /etc/xen/vms/thor.cfg_setup 
# cat /etc/xen/vms/thor.cfg_setup 
builder = 'hvm'
name = 'thor'
memory = '1024'
vcpus = 1
vif = ['bridge=xenbr0']
disk = ['phy:/dev/mini-vg/thor,hda,w','/var/lib/xen/images/centos7_minimal.iso,raw,hdc,ro,cdrom']
vnc = 1
vnclisten = '192.168.0.16'
boot = 'dc'
```

We need to create and start the virtual machine now.
```
# xl create /etc/xen/vms/thor.cfg
```

We need to be able to access vnc, so I set vnclisten to my local network IP. To determine the port I'll connect to with VNC, I just run this until I find the service shown as "qemu-system-i":
```
# netstat -plnt | grep -i listen
tcp        0      0 192.168.0.16:5900          0.0.0.0:*               LISTEN      11250/qemu-system-i
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1674/sshd       
tcp6       0      0 :::22                   :::*                    LISTEN      1674/sshd       
```

I now connect with VNC viewer to 192.168.0.16 over port 5900. The RDP client with most linux distros support VNC. I run the install and once I'm done, I update the virtual machine configuration and restart the virtual machine. Leave VNC accessible so that you can make sure to setup static networking. Also note, you can setup a static MAC address if you want to control IP assignments allowed with a switch or something.
```
# vim /etc/xen/vms/thor.cfg
# cat /etc/xen/vms/thor.cfg
builder = 'hvm'
name = 'thor'
memory = '1024'
vcpus = 1
vif = ['bridge=xenbr0']
disk = ['phy:/dev/mini-vg/thor,hda,w']
vnc = 1
vnclisten = '192.168.0.16'
boot = 'c'
# xl config-update thor /etc/xen/vms/thor.cfg
# xl reboot thor
```

Over VNC viewer, I ensured a static networking configuration in CentOS 7 and also update the hostname:
```
# hostname thor
# cat /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=thor
GATEWAY=192.168.0.1
# cat /etc/sysconfig/network-scripts/ifcfg-eth0 
TYPE=Ethernet
BOOTPROTO=static
NAME=eth0
UUID=d99dadcf-feb6-4782-b98c-d0fba48f10b4
ONBOOT=yes
IPADDR=192.168.0.24
```

After you guarantee networking is pimpin', move along and disable VNC viewer remotely, unless you want that type of thing:
```
# vim /etc/xen/vms/thor.cfg
# cat /etc/xen/vms/thor.cfg
builder = 'hvm'
name = 'thor'
memory = '1024'
vcpus = 1
vif = ['bridge=xenbr0']
disk = ['phy:/dev/mini-vg/thor,hda,w']
vnc = 1
IPADDR=127.0.0.1
boot = 'c'
# xl config-update thor /etc/xen/vms/thor.cfg
# xl reboot thor
```


If everything went well, you should have a persistent VM that will work forever.
