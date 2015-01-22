Document is a work in progress

The best getting started documentation for CentOS 7 I could really find is located here: https://openstack.redhat.com/Quickstart

I did not like how it setup cinder though. So I've changed it as follows. /dev/sda4 is a partition with all my space that is intended to be for VMs.
# pvcreate /dev/sda4
# vgcreate cinder-block /dev/sda4
# vim /etc/cinder/cinder.conf

I set the volume_group setting to the new volume group "cinder-block".
