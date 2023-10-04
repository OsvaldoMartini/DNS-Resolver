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

# NetPlan
```bash

network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: true

sudo netplan generate # generate config files

sudo netplan apply # apply config

reboot # reboot the compute
```
# Install sudo apt install yamllint.
```bash
 sudo apt install yamllint
 
 # Check Validate the File
 yamllint /etc/netplan/01-network-manager-all.yaml
 # Expected:
 01-network-manager-all.yaml
  1:81      error    line too long (203 > 80 characters)  (line-length)
  1:202     error    trailing spaces  (trailing-spaces)
  2:8       error    syntax error: mapping values are not allowed here (syntax)

```