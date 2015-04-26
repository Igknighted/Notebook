# Setting up some pseudo code

# need to get distro and version

# if rhel7

# need to check connectivity from slave to master....
# firewallcmd? or iptables? 
# iptables -I INPUT -p TCP --dport 3306 -j ACCEPT
# iptables-save


# we will automate this stuff first

# on the "MASTER" file /etc/my.cnf
log-bin=/var/lib/mysql/bin.log
binlog-format=MIXED
expire-logs-days=5
server-id={INSERT A UNIQUE NUMBER}

# on the "SLAVE" file /etc/my.cnf
relay-log=/var/lib/mysql/relay-log
relay-log-space-limit = 10G
read-only=1
server-id={INSERT A UNIQUE NUMBER}

#restart mysql on master
#restart mysql on slave

# on the master 
mysql > CREATE USER 'repl'@'%' IDENTIFIED BY 'PASSWORD';
mysql > GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
mysql > flush privileges;
mysqldump -A --flush-privileges --master-data=1 | gzip -1 > ~/masterdata_automater.sql.gz
rsync ~/masterdata_automater.sql.gz user@REMOTE.IP.ADD.RESS:~

# on the slave
zcat masterdata_automater.sql.gz | mysql
# get the master log file and log pos from
zgrep -m 1 -P 'CHANGE MASTER' masterdata_automater.sql.gz

mysql > CHANGE MASTER TO
    ->     MASTER_HOST='master_host_name',
    ->     MASTER_USER='replication_user_name',
    ->     MASTER_PASSWORD='replication_password',
    ->     MASTER_LOG_FILE='recorded_log_file_name', 
    ->     MASTER_LOG_POS=recorded_log_position;

mysql start slave;


# if rhel 6

# if ubuntu 14
