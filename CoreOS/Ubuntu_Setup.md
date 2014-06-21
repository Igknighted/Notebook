This is some generic setup instructions to setup a container running ubuntu.

We start by accessing our container to set it up with any services we need. We instruct docker to run interactively and open a TTY for ubuntu 14.04 LTS. When it opens up, it will run `su -`. I use su because it will load the needed bash profile.
```
# docker run -it ubuntu:14.04 su -
Unable to find image 'ubuntu:14.04' locally
Pulling repository ubuntu
e54ca5efa2e9: Download complete 
511136ea3c5a: Download complete 
d7ac5e4f1812: Download complete 
2f4b4d6a4a06: Download complete 
83ff768040a0: Download complete 
6c37f792ddac: Download complete 
```

I confirm the system is what I need:
```
root@6a4da44187a6:~# cat /etc/issue
Ubuntu 14.04 LTS \n \l
```

I'm going to install an SSH server in my container for example sake and I also need vim later:
```
root@6a4da44187a6:~# apt-get install openssh-server -y
```

Now we need to set the root password:
```
root@8bfdb0248c89:/# passwd
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
```

We need to allow root logins over SSH, so we're editing the SSHD config:
```
root@8bfdb0248c89:/# vim /etc/ssh/sshd_config 
```

Just make sure the following is commented out:
```
#PermitRootLogin without-password
#StrictModes yes
```

Once the command returns, I create a script to have docker initiate on start. Docker is meant to separate processes into containers, but sometimes you want to separate environments with multiple processes. I do the ladder in the following manner.

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
CONTAINER ID        IMAGE           COMMAND         CREATED             STATUS                          PORTS      NAMES
6a4da44187a6        ubuntu:14.04    su -            9 minutes ago       Exited (0) About a minute ago              prickly_leakey
```

I'm branching my changes into a new image tag called 14.04LTS by committing the changes I made:
```
# docker commit 6a4da44187a6 ubuntu:14.04LTS
902972a8d15f1cb8f80c6fd8346ece5a719d22ea4d6f6e02089588217c266fbb
```

Now to test my setup. In the next command I will be mounting the following directories
CoreOS:/home -> 14.04LTS:/home
CoreOS:/var/www -> 14.04LTS:/var/www
I will also be passing internet traffic to CoreOS:2122 <-> 14.04LTS:22 so SSH will be accessible.
```
# docker run -it -p 2122:22 -v /home:/home -v /var/www:/var/www ubuntu:14.04LTS /opt/docker.init
 * Starting OpenBSD Secure Shell server sshd                                                                    [ OK ] 
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

I'm going to now name my container ubuntu14 and start it for the first time:
```
# docker run --name ubuntu14 -d -p 2122:22 -v /home:/home -v /var/www:/var/www ubuntu:14.04LTS /opt/docker.init
696520d743549609486a24a1dc444c204bacd6c4628352b2d7f750efcb08436a
```

I do another SSH test to make sure it's accessible from a remote location:
```
# ssh root@MY_SERVER_IP -p2122
```

Now we can stop the container:
```
# docker stop ubuntu14
ubuntu14
```

We can start it up again:
```
# docker start ubuntu14
ubuntu14
```

We can see if it's running:
```
# docker ps
CONTAINER ID   IMAGE             COMMAND             CREATED             STATUS           PORTS                    NAMES
696520d74354   ubuntu:14.04LTS   /opt/docker.init    2 minutes ago       Up 18 seconds    0.0.0.0:2122->22/tcp     ubuntu14
```

The next thing to do is to add it to the system config. 
```
# vim /etc/systemd/system/ubuntu14.service
```

File now contains:
```
[Unit]
Description=Ubuntu Services
After=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/bash -c '/usr/bin/docker start -a ubuntu14'
ExecStop=/usr/bin/docker stop ubuntu14
ExecStopPost=/usr/bin/docker commit ubuntu14 ubuntu:14.04LTS


[Install]
WantedBy=multi-user.target
```


Now to add the systemctl configuration for the ubuntu14 service:
```
# systemctl enable /etc/systemd/system/ubuntu14.service
ln -s '/etc/systemd/system/ubuntu14.service' '/etc/systemd/system/multi-user.target.wants/ubuntu14.service'
```

Stop the container, in CoreOS, we will use systemctl to do this moving forward:
```
# docker stop ubuntu14
ubuntu14
```

Make sure it's not running:
```
# docker ps
```

Start it again with systemctl:
```
# systemctl start ubuntu14
```

Make sure it's running:
```
# docker ps
```

This should stop it. You should probably just test to make sure it works:
```
# systemctl stop ubuntu14
```
