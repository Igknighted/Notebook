This is some generic setup instructions to setup a container running CentOS 6.

We start by accessing our container to set it up with any services we need. We instruct docker to run interactively and open a TTY for CentOS 6. When it opens up, it will run `su -`. I use su because it will load the needed bash profile.
```
# docker run -it centos:centos6 su -
Unable to find image 'centos:centos6' locally
Pulling repository centos
```

I confirm the system is what I need:
```
root@6a4da44187a6:~# cat /etc/issue
CentOS release 6.5 (Final)
Kernel \r on an \m
```

I'm going to install an SSH server in my container for example sake and I also need vim later:
```
root@6a4da44187a6:~# yum install openssh-server -y
```

I had a problem running passwd because "/usr/share/cracklib/pw_dict.pwd" was missing:
```
yum reinstall cracklib-dicts -y
```

Now we need to set the root password:
```
root@8bfdb0248c89:/# passwd
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
```

This will fix locale problems in CentOS/RHEL:
```
# yum reinstall glibc-common -y
```

We need to allow root logins over SSH, so we're editing the SSHD config:
```
root@8bfdb0248c89:/# vim /etc/ssh/sshd_config 
```

Just make sure the following is commented out:
```
#PermitRootLogin
#StrictModes
```

Now we will create a script to have docker initiate on start. Docker is meant to separate processes into containers, but sometimes you want to separate environments with multiple processes. I do the ladder in the following manner.

I create /opt/docker.init:
```
root@6a4da44187a6:~# vim /opt/docker.init
```

It contains the following:
```
#!/bin/bash

/etc/init.d/ssh start

# This is to keep docker running even after init scripts are completed above
/bin/bash
```


Also make it executable:
```
chmod +x /opt/docker.init
```

Now we're done with setting up our system to be remotely accessible. So now we drop back to CoreOS
```
root@6a4da44187a6:~# exit
logout
```

We need the ID of the container we were just in:
```
# docker ps -l 
CONTAINER ID        IMAGE            COMMAND         CREATED             STATUS                          PORTS      NAMES
6a4da44187a6        centos:centos6   su -            9 minutes ago       Exited (0) About a minute ago              prickly_leakey
```

I'm branching my changes into a new image tag called cent01 by committing the changes I made:
```
# docker commit 6a4da44187a6 centos:cent01
902972a8d15f1cb8f80c6fd8346ece5a719d22ea4d6f6e02089588217c266fbb
```

Now to test my setup. In the next command I will be mounting the following directories
CoreOS:/home -> cent01:/home
CoreOS:/var/www -> cent01:/var/www
I will also be passing internet traffic to CoreOS:2122 <-> cent01:22 so SSH will be accessible.
```
# docker run -it -p 2122:22 -v /home:/home -v /var/www:/var/www centos:cent01 /opt/docker.init
 Starting sshd                                                                    [ OK ] 
root@8bfdb0248c89:/#
```

Before we drop our shell, we can try to SSH to our CoreOS server over port 2122 now, so run this from somewhere:
```
# ssh root@MY_SERVER_IP -p2122
```

After we know it works, we can now exit the container:
```
root@6a4da44187a6:~# exit
logout
```

I'm going to now name my container web1 and start it for the first time:
```
# docker run --name web1 -dit -p 2122:22 -v /home:/home -v /var/www:/var/www centos:cent01 /opt/docker.init
696520d743549609486a24a1dc444c204bacd6c4628352b2d7f750efcb08436a
```

I do another SSH test to make sure it's accessible from a remote location:
```
# ssh root@MY_SERVER_IP -p2122
```

Now we can stop the container:
```
# docker stop web1
web1
```

We can start it up again:
```
# docker start web1
web1
```

We can see if it's running:
```
# docker ps
CONTAINER ID   IMAGE             COMMAND             CREATED             STATUS           PORTS                    NAMES
696520d74354   centos:cent01     /opt/docker.init    2 minutes ago       Up 18 seconds    0.0.0.0:2122->22/tcp     web1
```

The next thing to do is to add it to the system config. 
```
# vim /etc/systemd/system/web1.service
```

File now contains:
```
[Unit]
Description=CentOS6 Services
After=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/bash -c '/usr/bin/docker start -a web1'
ExecStop=/usr/bin/docker stop web1
ExecStopPost=/usr/bin/docker commit web1 centos:cent01


[Install]
WantedBy=multi-user.target
```


Now to add the systemctl configuration for the web1 service:
```
# systemctl enable /etc/systemd/system/web1.service
ln -s '/etc/systemd/system/web1.service' '/etc/systemd/system/multi-user.target.wants/web1.service'
```

Stop the container, we will use systemd to do this moving forward:
```
# docker stop web1
web1
```

Make sure it's not running:
```
# docker ps
```

Start it again with systemctl:
```
# systemctl start web1
```

Make sure it's running:
```
# docker ps
```

This should stop it. You should probably just test to make sure it works:
```
# systemctl stop web1
```
