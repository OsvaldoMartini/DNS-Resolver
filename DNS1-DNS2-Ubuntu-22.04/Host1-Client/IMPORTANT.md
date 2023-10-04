# Ubuntu 22.04

[How To Configure BIND as a Private Network DNS Server on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-22-04)


# VERY IMPORTANT
## Chke the Name ot the Network Adapter
```bash
 # Ubuntu
 amazonlinux$  ip address show to 10.128.0.0/16 

 # Ubuntu
 vmlilnux1$  ip address show to 10.128.0.0/16 

```

## On Ubuntu 22.04 Uses Netpaln
* On Ubuntu 22.04, networking is configured with Netplan, 
* an abstraction that allows you to write standardized network configuration and apply it to compatible backend networking software. 
* To configure * DNS, you need to write a Netplan configuration file.
> Create a new file in /etc/netplan called 00-private-nameservers.yaml:
```bash
  sudo nano /etc/netplan/00-private-nameservers.yaml
```
