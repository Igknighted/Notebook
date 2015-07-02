#!/bin/bash

############ INCOMPLETE


export DATESTAMP=$(date +%Y%m%d)

if [ "$1" == "install" ]; then
  export BLOCK_STORAGE=$2
  
  if firewall-cmd --state; then
    firewall-cmd --zone=public --add-source=192.168.0.0/16 --permanent
    firewall-cmd --reload
  else
    iptables -I INPUT -s 192.168.0.0/16 -j ACCEPT
    iptables-save
  fi
  
  cd /etc/yum.repos.d && wget http://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/glusterfs-epel.repo
  yum install -y parted lvm2 xfsprogs glusterfs{,-server,-fuse,-geo-replication}
  
  # if is rhel7
  systemctl enable glusterd
  systemctl restart glusterd
  
  
  # setup the brick
  parted -s -- $BLOCK_STORAGE mktable gpt
  parted -s -- $BLOCK_STORAGE mkpart primary 2048s 100%
  parted -s -- $BLOCK_STORAGE set 1 lvm on
  partx -a $BLOCK_STORAGE
  pvcreate $BLOCK_STORAGE'1'
  vgcreate vgglus_$DATESTAMP $BLOCK_STORAGE'1'
  lvcreate -l 100%VG -n gbrick_$DATESTAMP vgglus_$DATESTAMP
  mkfs.xfs -i size=512 /dev/vgglus_$DATESTAMP/gbrick_$DATESTAMP
  echo '/dev/vgglus_'$DATESTAMP'/gbrick_'$DATESTAMP' /var/lib/gvol_'$DATESTAMP' xfs inode64,nobarrier 0 0' >> /etc/fstab
  mkdir -p /var/lib/gvol_$DATESTAMP
  echo "/dev/vgglus_"$DATESTAMP"/gbrick_"$DATESTAMP" /var/lib/gvol_"$DATESTAMP" xfs defaults 0 0"  >> /etc/fstab
  mount /var/lib/gvol_$DATESTAMP
  mkdir /var/lib/gvol_$DATESTAMP/brick
fi

if [ "$1" == "first" ]; then
  export PRIMARY_NODE_IP=$2
  export CURRENT_NODE_IP=$3
  export BLOCK_STORAGE=$4
  
  gluster peer probe $PRIMARY_NODE_IP
  gluster peer probe $CURRENT_NODE_IP
  
  
  gluster volume create gvol_$DATESTAMP replica 1 transport tcp $CURRENT_NODE_IP:/var/lib/gvol_$DATESTAMP/brick
  gluster volume set gvol_$DATESTAMP auth.allow 192.168.*.*
  gluster volume set gvol_$DATESTAMP nfs.disable off
  gluster volume set gvol_$DATESTAMP nfs.addr-namelookup off
  gluster volume set gvol_$DATESTAMP nfs.export-volumes on
  gluster volume set gvol_$DATESTAMP nfs.rpc-auth-allow 192.168.*.*
  gluster volume start gvol_$DATESTAMP
fi

if [ "$1" == "add" ]; then
  export CURRENT_NODE_IP=$2
  export BLOCK_STORAGE=$3
  
  gluster volume add-brick gvol_$DATESTAMP replica $NODE_NUM $CURRENT_NODE_IP:/var/lib/gvol_$DATESTAMP/brick
fi



mkdir -p /mnt/gluster/gvol_$DATESTAMP
echo '10.176.11.102:/gvol_'$DATESTAMP'    /mnt/gluster/gvol_'$DATESTAMP'    glusterfs defaults 0 0' >> /etc/fstab
mount /mnt/gluster/gvol_$DATESTAMP


glu2# echo Hello World > /mnt/gluster/testing_glu1

glu1# echo '10.176.12.77:/gvol_'$DATESTAMP'    /mnt/gluster/gvol_'$DATESTAMP'    glusterfs defaults 0 0' >> /etc/fstab

glu1# mkdir -p /mnt/gluster/gvol_$DATESTAMP;
glu1# mount /mnt/gluster/gvol_$DATESTAMP

glu1# cat /mnt/gluster/testing_glu1
glu1# echo It works > /mnt/gluster/testing_glu1

glu2# cat /mnt/gluster/testing_glu1
