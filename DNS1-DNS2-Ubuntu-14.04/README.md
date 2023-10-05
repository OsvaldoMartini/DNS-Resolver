# Ubuntu DNS1 & DNS2 & WebServer

[How To Configure Bind as an Authoritative-Only DNS Server on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-an-authoritative-only-dns-server-on-ubuntu-14-04)

# VERY IMPORTANT

## EVERYTIME CHANGING THE FILES
# UPDATE THE SERIAL NUMBER
# TO REFLECT THE UPDATES CHANGES INSIDE ON BIND
```bash
  ...
        5         ; Serial
  ...
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
  sudo service bind9 restart
```

## Check the BIND9 Logs
```bash
  sudo tail -f /var/log/syslog
```

# Set Host Name Ubuntu
```bash
  # Info
  hostnamectl

  #Set Hostname
  sudo hostname dnsserver

 # It Sets Static hostname
  hostnamectl set-hostname new-hostname
```
