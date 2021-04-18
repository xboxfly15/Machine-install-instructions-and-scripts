---
title: Setup IPv6
---
### Ubuntu:
The network configuration files are located in /etc/netplan/  
```
cd /etc/netplan
```

Create a file named 51-cloud-init-ipv6.yaml inside of /etc/netplan/  
```
touch 51-cloud-init-ipv6.yaml
```
Edit the 51-cloud-init-ipv6.yaml file, adding the IPv6 configuration below. Take care to change IPV6_ADDRESS, IPV6_PREFIX and IPV6_GATEWAY to your servers information and also the network interface, if you are not using eth0. You can find the network interface by looking in 50-cloud.init.yaml and seeing what `name:` says.
```  
nano 51-cloud-init-ipv6.yaml
```
For OVH the IPV6_PREFIX is normally 128 but may be 64 and network interface name is normally ens3.  
```
network:
    version: 2
    ethernets:
        eth0:
            dhcp6: no
            match:
              name: eth0
            addresses:
              - "IPV6_ADDRESS/IPV6_PREFIX"
            gateway6: "IPV6_GATEWAY"
```
If you're using Ubuntu 20.04 add this to the bottom of the file as well  
```
            routes:
              - to: "IPV6_GATEWAY"
                scope: link
```

Test the configuration using this command:  
```
netplan try
```
If there are no errors, apply it, using the following command:  
```
netplan apply
```
Ubuntu DONE, your machine should now be IPv6 accessible  

### CentOS:
The network configuration files are located in /etc/sysconfig/network-scripts/  

Back up the IPv4 configuration file, copy the ifcfg-eth0 file using the following commands:  
```
cd /etc/sysconfig/network-scripts/
mkdir backup
cp ifcfg-eth0 backup/ifcfg-eth0
```

You can then revert back in case of error, using the commands below:  
```
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
cp /etc/sysconfig/network-scripts/backup/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
```
Edit the ifcfg-eth0 file, adding the IPv6 configuration to the end of the file, whist keeping everything above it. Take care to change IPV6_ADDRESS, IPV6_PREFIX and IPV6_GATEWAY to your servers information.  
Your IPV6_PREFIX may be 64 or 128.  
```
IPV6INIT=yes
IPV6ADDR=IPV6_ADDRESS/IPV6_PREFIX
IPV6_DEFAULTGW=IPV6_GATEWAY
```

Create a file named route6-eth0 inside of /etc/sysconfig/network-scripts/  
Edit the route6-eth0 file, adding the IPv6 configuration below. Take care to change IPV6_GATEWAY to your servers information.  
```
IPV6_GATEWAY dev eth0
default via IPV6_GATEWAY
```

Once all that has been done, execute the following command to restart the network service to use the new configuration  
```
service network restart
```
Your machine should now be IPv6 accessible BUT it will reset when the machine reboots due to cloud-init, let's fix that by disabling cloud-init's network management  
Execute the following command to disable the cloud-init network management  
```
echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/98-disable-network-config.cfg
```
CentOS DONE, the IPv6 configuration will not reset now
