Check if any services failed after a host reboot (RHEL/CentOS 7):
```
root@localhost # systemctl -a | grep failed | grep openstack
```

