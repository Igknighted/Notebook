#!/bin/bash
DATESTAMP=$(date +%Y%m%d)

# BEGIN: Detect the OS information
if [ -f /etc/os-release ]; then
	. /etc/os-release
elif grep -q 'release 6' /etc/redhat-release; then
	DISTRO="rhel"
	VERSION_ID="6"
else
	echo ERROR: File /etc/os-release does not exist.
	exit 1
fi

# Detect the linux distro
if [ -f /etc/redhat-release ]; then
	DISTRO="rhel"
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


if [ "$1" == "" ]; then
	echo 'glu.sh'
	echo
	echo 'GlusterFS deployment script.'
	echo
	echo 'Usage:'
	echo
	echo './glu.sh auto'
	echo '     This will walk you through the install process step by step.'
	echo
	echo
	echo 'These are the manual steps for setting up first two nodes'
	echo '     ./glu.sh install (/dev/xvd[b-z] | optional)'
	echo '          This needs to be ran on both the servers to setup gluster services and bricks.'
	echo '     ./glu.sh connect [Private IP of Node 1] [Private IP of Node 2]'
	echo '          This only needs to be ran on only ONE of the servers to setup the gluster volume.'
	echo '     ./glu.sh mount'
	echo '          This must be ran on both servers after the connect command. This will mount the gluster volume.'
	echo
	echo
	echo 'These are the steps for adding new nodes after the first two are setup.'
	echo '     ./glu.sh install (/dev/xvd[b-z] | optional)'
	echo '          This needs to be ran on all the servers to setup gluster services and bricks.'
	echo '     ./glu.sh add [Private IP of another Node]'
	echo '          Run this from an existing node after running "./glu.sh install" to add the new node.'
	echo '     ./glu.sh mount'
	echo '          This must be ran on the new servers after the add command. This will mount the gluster volume.'
	
	exit
fi

if [ "$1" == "auto" ]; then 
	read -p "Block storage location (For example, /dev/xvdb | or leave empty for auto detection): " BLOCK_STORAGE
	$0 install $BLOCK_STORAGE
	echo
	echo
	read -p 'Go run "./glu.sh install" on the other server node now before you proceed. Once done, press enter to continue.' NOVAR
	read -p "What is the IP or hostname for NODE 1: " NODE1_IP
	read -p "What is the IP or hostname for NODE 2: " NODE2_IP
	$0 connect $NODE1_IP $NODE2_IP
	$0 mount
	echo
	echo
	echo 'Go run "./glu.sh mount" on the other server node now and you should be done.'
fi


if [ "$1" == "install" ]; then 
	if [ ! -b $2 ] && [ "$2" != "" ]; then
		echo Block storage $2 not found.
		exit
	fi
	
	if [ "$2" != "" ]; then
		BLOCK_STORAGE=$2
	else
		EMPTY_STORAGE_COUNT=$(parted -l 2>&1 | tr -d ':'  | grep -E '^Disk /|^Partition Table' | awk 'BEGIN{dev=""}{if($1 == "Disk"){dev=$2}else{if($3 == "unknown"){print dev}}}' | wc -l)
		
		if [ "$EMPTY_STORAGE_COUNT" != "1" ] && [ "$2" == "" ]; then
		  echo There are $EMPTY_STORAGE_COUNT empty storage devices
		  parted -l 2>&1 | tr -d ':'  | grep -E '^Disk /|^Partition Table' | awk 'BEGIN{dev=""}{if($1 == "Disk"){dev=$2}else{if($3 == "unknown"){print dev}}}'
		  exit
		fi
		
		BLOCK_STORAGE=$(parted -l 2>&1 | tr -d ':'  | grep -E '^Disk /|^Partition Table' | awk 'BEGIN{dev=""}{if($1 == "Disk"){dev=$2}else{if($3 == "unknown"){print dev}}}')
	fi
	
	# allow in firewall...
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
	echo Running parted...
	parted -s -- $BLOCK_STORAGE mktable gpt
	parted -s -- $BLOCK_STORAGE mkpart primary 2048s 100%
	parted -s -- $BLOCK_STORAGE set 1 lvm on
	partx -a $BLOCK_STORAGE
	
	echo Setting up logical volume and xfs file system...
	pvcreate $BLOCK_STORAGE'1'
	vgcreate vgglus_$DATESTAMP $BLOCK_STORAGE'1'
	lvcreate -l 100%VG -n gbrick_$DATESTAMP vgglus_$DATESTAMP
	mkfs.xfs -i size=512 /dev/vgglus_$DATESTAMP/gbrick_$DATESTAMP
	
	echo Adding mount data to /etc/fstab
	echo '/dev/vgglus_'$DATESTAMP'/gbrick_'$DATESTAMP' /data/gluster/gvol_'$DATESTAMP' xfs inode64,nobarrier 0 0' >> /etc/fstab
	
	echo Creating mount point and mounting /data/gluster/gvol_$DATESTAMP
	mkdir -p /data/gluster/gvol_$DATESTAMP
	mount /data/gluster/gvol_$DATESTAMP
	
	echo Creating brick dir...
	mkdir /data/gluster/gvol_$DATESTAMP/brick
	
	echo; echo
	echo Showing df output below.
	echo
	df -h
	
	
	echo
	echo
	echo 'Now go run "./glu.sh connect [NODE_1_IP]  [NODE_2_IP]" from only ONE NODE after install was done on both'
fi



if [ "$1" == "connect" ]; then
	if [ "$3" == "" ]; then
		echo You must specify 2 IP addresses or hostnames to this command for it to work.
		exit
	fi
	
	NODE1_IP=$2
	NODE2_IP=$3
	
	gluster peer probe $NODE1_IP
	gluster peer probe $NODE2_IP
	
	
	gluster volume create gvol_$DATESTAMP replica 2 transport tcp $NODE1_IP:/data/gluster/gvol_$DATESTAMP/brick $NODE2_IP:/data/gluster/gvol_$DATESTAMP/brick
	gluster volume set gvol_$DATESTAMP auth.allow 192.168.*.*
	gluster volume set gvol_$DATESTAMP nfs.disable off
	gluster volume set gvol_$DATESTAMP nfs.addr-namelookup off
	gluster volume set gvol_$DATESTAMP nfs.export-volumes on
	gluster volume set gvol_$DATESTAMP nfs.rpc-auth-allow 192.168.*.*
	gluster volume start gvol_$DATESTAMP
	
	echo
	echo
	echo 'Now go run "./glu.sh mount" on '$NODE1_IP' and '$NODE2_IP
fi
  

if [ "$1" == "mount" ]; then
	echo Mounting the gluster volume at /mnt/gluster/gvol_$DATESTAMP
	NODE1_IP=$(gluster peer status | grep Hostname: | head -n1 | awk '{print $2}')
	mkdir -p /mnt/gluster/gvol_$DATESTAMP
	echo $NODE1_IP':/gvol_'$DATESTAMP'    /mnt/gluster/gvol_'$DATESTAMP'    glusterfs defaults 0 0' >> /etc/fstab
	mount /mnt/gluster/gvol_$DATESTAMP
	
	echo
	echo
	echo Testing things out...
	if [ -f /mnt/gluster/gvol_$DATESTAMP/rs_testfile ]; then
		echo File /mnt/gluster/gvol_$DATESTAMP/rs_testfile exists, reading it:
		cat /mnt/gluster/gvol_$DATESTAMP/rs_testfile
	else
		echo Creating test file /mnt/gluster/gvol_$DATESTAMP/rs_testfile so that during the mount on the other server, it will test reading it.
		echo 'Hello World' > /mnt/gluster/gvol_$DATESTAMP/rs_testfile
	fi
fi



if [ "$1" == "add" ]; then
	NODE1_IP=$2
	
	gluster peer probe $NODE1_IP
	if [ "$?" ==  "0" ]; then
		VOLUME_NAME=$(gluster volume info | grep '^Volume Name:' | awk '{print $3}')
		NODE_NUM=$(gluster pool list | grep -v ^UUID | wc -l)
		
		gluster volume add-brick $VOLUME_NAME replica $NODE_NUM $NODE1_IP:/data/gluster/gvol_$DATESTAMP/brick
		
		echo
		echo
		echo 'Now go run "./glu.sh mount" on '$NODE1_IP
	fi
fi
