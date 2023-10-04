# Ubuntu DNS1 & DNS2 & WebServer

[How To Configure BIND as a Private Network DNS Server on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-22-04)


# VERY IMPORTANT

## EVERYTIME CHANGING THE FILES
# UPDATE THE SERIAL NUMBER
# TO REFLECT THE UPDATES CHANGES INSIDE ON BIND
```bash
  ...
        5         ; Serial
  ...
```

# Architerues
Host	    Role	                Private FQDN	          Private IP Address
ns1	    Primary DNS Server	  ns1.nyc3.example.com	  10.128.10.11
ns2	    Secondary DNS Server	ns2.nyc3.example.com	  10.128.20.12
host1	  Generic Host 1	      host1.nyc3.example.com	10.128.100.101
host2	  Generic Host 2	      host2.nyc3.example.com	10.128.200.102

# Shifthunter.com
Host	    Role	                Private FQDN	          Private IP Address
ns1	    Primary DNS Server	  ns1.shifthunter.com.com	  192.168.1.65
ns2	    Secondary DNS Server	ns2.shifthunter.com.com	  192.168.1.66
host1	  Generic Host 1	      host1.shifthunter.com.com	192.168.1.63  # amazonlinux
host2	  Generic Host 2	      host2.shifthunter.com.com	172.168.1.57  # vmlinux1

## BIN Defaukt IPV4
```bash
  sudo  nano /etc/default/named

  . . .
 OPTIONS="-u bind -4"
```




# Checking the Files and Configs
```bash
  # Checking the "conf" files
  sudo named-checkconf

# Checking the Zones
sudo named-checkzone shifthunter.com /etc/bind/zones/db.shifthunter.com
# Expected:
zone example.com/IN: loaded serial 5
OK
# Checking the Reverse Lookup
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
# Expected:
zone 1.168.192.in-addr.arpa/IN: loaded serial 5
OK
```
## Restart the BIND9 Service
```bash
  sudo systemctl restart bind9
```
## Firewall Permission
```bash
  sudo ufw allow Bind9
```


## Check the BIND9 Logs
```bash
  sudo tail -f /var/log/syslog
```
## Step 4 — Configuring DNS Clients  "amazonlinux" or "vmlilnux1"
```bash
 amazonlinux$  ip address show to 10.128.0.0/16 

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
