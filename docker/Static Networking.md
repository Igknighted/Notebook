Static Networking
=================
Something that is really needed between containers is a way to communicate amongst each other. Using the -p EXTERNAL_PORT:CONTAINER_PORT with "docker run" is pretty straight forward. You can even do -p HOST_IP:EXTERNAL_PORT:CONTAINER_PORT to specify the interface.

However the docker interface that the containers network through uses DHCP. There is currently no way around that. However we can use pipe works to maintain static IPs:

```
# pipework docker0 -i eth1 CONTAINER_NAME_OR_ID 10.2.0.12/16
```

If we use systemd, we can have it automatically bring up our networking after the container is up:
```
# cat /etc/systemd/system/ubuntu14.service 
[Unit]
Description=Ubuntu Services
After=docker.service
Requires=docker.service

[Service]
ExecStart=/bin/bash -c '/usr/bin/docker start -a ubuntu14'
ExecStartPost=/root/bin/pipework docker0 -i eth1 ubuntu14 10.2.0.12/16
ExecStop=/usr/bin/docker stop ubuntu14


[Install]
WantedBy=multi-user.target
```


Pipework can be attained from: https://github.com/jpetazzo/pipework/
