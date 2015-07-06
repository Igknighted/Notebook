#!/bin/bash
DATESTAMP=$(date +%Y%m%d)

# BEGIN: Detect the OS information
if [ -f /etc/os-release ]; then
	. /etc/os-release
else
	echo ERROR: File /etc/os-release does not exist.
	exit 1
fi

if [ -f /etc/redhat-release ]; then
	DISTRO="rhel"
	echo Detected RHEL based distro.
elif [ "$NAME" == "Ubuntu" ]; then
	DISTRO="ubuntu"
	echo Detected Ubuntu based distro.
	echo Currently unsupported
	exit
elif [ "$NAME" == "Debian GNU/Linux" ]; then
	DISTRO="debian"
	echo Detected Debian based distro.
	echo Currently unsupported
	exit
else
	echo ERROR: This server is not running a supported distro.
	exit 1
fi
# END: Detect the OS information





if [ "$1" == "install" ]; then 
  BLOCK_STORAGE=$2

  if firewall-cmd --state; then
    firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.0.0/16" accept'
    firewall-cmd --reload
  else
    iptables -I INPUT -s 192.168.0.0/16 -j ACCEPT
    iptables-save
  fi
  
  cd /etc/yum.repos.d && wget http://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/glusterfs-epel.repo
  yum install -y parted lvm2 xfsprogs glusterfs{,-server,-fuse,-geo-replication}
  
	# BEGIN: Enable and start the glusterd service
	if [ "$DISTRO" == "rhel" ] && [ "$VERSION_ID" == "7" ]; then
		systemctl enable glusterd
		systemctl restart glusterd
	elif [ "$DISTRO" == "rhel" ] && [ "$VERSION_ID" == "6" ]; then
		service glusterd restart
		chkconfig glusterd on
	fi
  # END: Enable and start the glusterd service


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



if [ "$1" == "connect" ]; then
  export NODE1_IP=$2
  export NODE2_IP=$3
  
  gluster peer probe $NODE1_IP
  gluster peer probe $NODE2_IP
  
  
  gluster volume create gvol_$DATESTAMP replica 2 transport tcp $NODE1_IP:/var/lib/gvol_$DATESTAMP/brick $NODE2_IP:/var/lib/gvol_$DATESTAMP/brick
  gluster volume set gvol_$DATESTAMP auth.allow 192.168.*.*
  gluster volume set gvol_$DATESTAMP nfs.disable off
  gluster volume set gvol_$DATESTAMP nfs.addr-namelookup off
  gluster volume set gvol_$DATESTAMP nfs.export-volumes on
  gluster volume set gvol_$DATESTAMP nfs.rpc-auth-allow 192.168.*.*
  gluster volume start gvol_$DATESTAMP
fi
  

if [ "$1" == "mount" ]; then
  export NODE1_IP=$2
  mkdir -p /mnt/gluster/gvol_$DATESTAMP
  echo $NODE1_IP':/gvol_'$DATESTAMP'    /mnt/gluster/gvol_'$DATESTAMP'    glusterfs defaults 0 0' >> /etc/fstab
  mount /mnt/gluster/gvol_$DATESTAMP
fi
