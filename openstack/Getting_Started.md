Document is a work in progress

Pre-OpenStack setup, I installed CentOS 7. I had to use this to make the thumbstick from the ISO on my Windows PC (gaming unit, don't judge me): http://sourceforge.net/projects/win32diskimager/

The setup was purely the minimal install without networking. This was important because if the tools used to setup networking during install are used, you could end up with a headache if you can't figure out what network.service is bitching about upon attempting to start. The startup log was not very helpful in my review during testing. (Needs more data)

Disabled SE linux before proceeding any further.

The best getting started documentation for CentOS 7 I could really find is located here: https://openstack.redhat.com/Quickstart

I did not like how it setup cinder. So I've changed it as follows. /dev/sda4 is a partition with all my space that is intended to be for VMs.
```
root@localhost # pvcreate /dev/sda4
root@localhost # vgcreate cinder-block /dev/sda4
root@localhost # vim /etc/cinder/cinder.conf
root@localhost # systemctl restart openstack-cinder-volume
```
I set the volume_group setting to the new volume group "cinder-block".

Another problem was witht he br-ex interface it created by default with the demo. Had to edit the file /etc/sysconfig/network-scripts/ifcfg-br-ex to read as follows:
```
DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
#IPADDR=172.24.4.225_br_ex
#NETMASK=255.255.255.240_br_ex
IPADDR=172.24.4.225
NETMASK=255.255.255.240
ONBOOT=yes
```
