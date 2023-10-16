# DNBS Bind Debian 12

## How To Install <span style="color: yellow;">bind9</span> on Debian 10
## DNS <span style="color: yellow;">Quad9</span> 

Installing BIND on DNS Servers


On both DNS servers, ns1 and ns2, update the apt package cache by typing:
```bash
sudo apt update
```
Now install BIND:
```bash
sudo apt install bind9 bind9utils bind9-doc

or

apt-get install bind9 bind9utils bind9-dnsutils bind9-doc bind9-host -y
```

Setting Bind to IPv4 Mode
Before continuing, let’s set BIND to IPv4 mode since our private networking uses IPv4 exclusively. On both servers, edit the bind9 default settings file by typing:
```bash
sudo nano /etc/default/bind9
```
Add “-4” to the end of the OPTIONS parameter. It should look like the following:
```bash
OPTIONS="-u bind -4"
```
Save and close the file when you are finished.

Restart BIND to implement the changes:
```bash
sudo systemctl restart bind9

sudo systemctl status bind9
```

## Configuring the Primary DNS Server
BIND’s configuration consists of multiple files, which are included from the main configuration file, named.conf. These filenames begin with named because that is the name of the process that BIND runs (short for “domain name daemon”). We will start with configuring the options file.

Configuring the Options File
On ns1, open the named.conf.options file for editing:
```bash
sudo nano /etc/bind/named.conf.options
```
Above the existing options block, create a new ACL (access control list) block called “trusted”. This is where we will define a list of clients that we will allow recursive DNS queries from (i.e. your servers that are in the same datacenter as ns1). Using our example private IP addresses, we will add ns1, ns2, host1, and host2 to our list of trusted clients:

```bash
acl "trusted" {
        192.168.1.50;  # ns1 - admin-node -> can be set to localhost
        192.168.1.55;  # ns2 -> master-node -> kafka - Server
        192.168.1.60;  # worker01-node -> Web Apps 
        192.168.1.70;  # worker02-node -> Java Apps
};
```
Now that we have our list of trusted DNS clients, we will want to edit the options block. Currently, the start of the block looks like the following:

Below the directory directive, add the highlighted configuration lines (and substitute in the proper ns1 IP address) so it looks something like this:
```bash
        . . .

};

options {
        directory "/var/cache/bind";
        
        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients
        listen-on { 10.128.10.11; };   # ns1 private IP address - listen on private network only
        allow-transfer { none; };      # disable zone transfers by default

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };

        . . .
};
```
When you are finished, save and close the named.conf.options file. The above configuration specifies that only your own servers (the “trusted” ones) will be able to query your DNS server for outside domains.

Next, we will configure the local file, to specify our DNS zones.

Configuring the Local File
On ns1, open the named.conf.local file for editing:
```bash
sudo nano /etc/bind/named.conf.local
```
Aside from a few comments, the file should be empty. Here, we will specify our forward and reverse zones. DNS zones designate a specific scope for managing and defining DNS records. Since our domains will all be within the “nyc3.example.com” subdomain, we will use that as our forward zone. Because our servers’ private IP addresses are each in the 10.128.0.0/16 IP space, we will set up a reverse zone so that we can define reverse lookups within that range.

Add the forward zone with the following lines, substituting the zone name with your own and the secondary DNS server’s private IP address in the *allow-transfer* directive:
```bash
zone "intranet.com" {
    type primary;
    file "/etc/bind/zones/db.intranet.com";
    allow-transfer { 192.168.1.55; }; # ns2 private IP address - secondary
};
```
Assuming that our private subnet is 192.168.1.0/24, add the reverse zone by with the following lines (note that our reverse zone name starts with “168.192” which is the octet reversal of 192.168”):
```bash
zone "1.168.192.in-addr.arpa" {
    type primary;
    file "/etc/bind/zones/db.192.168.1";
    allow-transfer { 192.168.1.55; };  # ns2 private IP address - secondary
};
```
If your servers span multiple private subnets but are in the same datacenter, be sure to specify an additional zone and zone file for each distinct subnet. When you are finished adding all of your desired zones, save and exit the named.conf.local file.

Now that our zones are specified in BIND, we need to create the corresponding forward and reverse zone files.

## Creating the Forward Zone File
The forward zone file is where we define DNS records for forward DNS lookups. That is, when the DNS receives a name query, “host1.nyc3.example.com” for example, it will look in the forward zone file to resolve host1’s corresponding private IP address.

Let’s create the directory where our zone files will reside. According to our named.conf.local configuration, that location should be /etc/bind/zones:
```bash
sudo mkdir /etc/bind/zones
```
We will base our forward zone file on the sample db.local zone file. Copy it to the proper location with the following commands:
```bash
sudo cp /etc/bind/db.local /etc/bind/zones/db.intranet.com
```
Now let’s edit our forward zone file:

```bash
sudo nano /etc/bind/zones/db.intranet.com
```
## Important <span style="color: yellow;">SERIAL</span> number
First, you will want to edit the SOA record. Replace the first “localhost” with ns1’s FQDN, then replace “root.localhost” with “admin.nyc3.example.com”. Every time you edit a zone file, you need to increment the serial value before you restart the named process. We will increment it to “3”. It should now look something like this:
```bash
$TTL    604800
@       IN      SOA     ns1.intranet.com. admin.intranet.com. (
                  3     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL
;
; name servers - NS records
     IN      NS      ns1.intranet.com.
     IN      NS      ns2.intranet.com.

; name servers - A records
ns1.intranet.com.          IN      A       192.168.1.50
ns2.intranet.com.          IN      A       192.168.1.55

; 10.128.0.0/16 - A records
;host1.intranet.com.        IN      A      10.128.100.101
;host2.intranet.com.        IN      A      10.128.200.102

; 192.168.0/24 - A records
worker01.intranet.com.      IN      A      192.168.1.60
worker02.intranet.com.      IN      A      192.168.1.70
amazonlinux.intranet.com.   IN      A      192.168.1.63
```

Now let’s move onto the reverse zone file(s).

Creating the Reverse Zone File(s)
Reverse zone files are where we define DNS PTR records for reverse DNS lookups. That is, when the DNS receives a query by IP address, “10.128.100.101” for example, it will look in the reverse zone file(s) to resolve the corresponding FQDN, “host1.nyc3.example.com” in this case.

On ns1, for each reverse zone specified in the named.conf.local file, create a reverse zone file. We will base our reverse zone file(s) on the sample db.127 zone file. Copy it to the proper location with the following commands (substituting the destination filename so it matches your reverse zone definition):
```bash
sudo cp /etc/bind/db.127 /etc/bind/zones/db.192.168.1
```
Edit the reverse zone file that corresponds to the reverse zone(s) defined in named.conf.local:
```bash
sudo nano /etc/bind/zones/db.192.168.1
```
## Important <span style="color: yellow;">SERIAL</span> number
In the same manner as the forward zone file, you will want to edit the SOA record and increment the serial value. It should look something like this:
```bash
$TTL    604800
@       IN      SOA     intranet.com. admin.intranet.com. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; name servers
      IN      NS      ns1.intranet.com.
      IN      NS      ns2.intranet.com.

; PTR Records
50       IN      PTR      ns1.intranet.com.
55       IN      PTR      ns2.intranet.com.
60       IN      PTR      worker01.intranet.com.
70       IN      PTR      worker02.intranet.com.
63       IN      PTR      amazonlinux.intranet.com.

;11.10   IN      PTR     ns1.intranet.com.    ; 10.128.10.11
;12.20   IN      PTR     ns2.intranet.com.    ; 10.128.20.12
;101.100 IN      PTR     host1.intranet.com.  ; 10.128.100.101
;102.200 IN      PTR     host2.intranet.com.  ; 10.128.200.102
```
We’re done editing our files, so next we can check our files for errors.

Checking the BIND Configuration Syntax
Run the following command to check the syntax of the named.conf* files:
```bash
sudo named-checkconf
```
Check the  Zones

```bash
sudo named-checkzone intranet.com /etc/bind/zones/db.intranet.com
```

```bash
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
```
Restarting BIND
Restart BIND:

```bash
sudo systemctl restart bind9
```
If you have the UFW firewall configured, open up access to BIND by typing:
```bash
sudo ufw allow Bind9
```


Configuring DNS Clients
```bash

```




5) Allow Local User to Run Docker Command
To allow local user to run docker commands without sudo, add the user to docker group (secondary group) using usermod command.

```bash

$ sudo usermod -aG bind $USER

$ newgrp bind
```

# <span style="color: yellow;">resolvconf</span> Install
Install <span style="color: yellow;">ResolvConf</span>   instead of <span style="color: yellow;">openresolv</span> 
[ResolvConf or openresolv](https://wiki.debian.org/resolv.conf)
[Install ResolvConf](https://installati.one/install-resolvconf-debian-11/)

* Step 1: If you are not already logged in as root, you need to get root privileges first:
```bash
su - $USER
```

* Step 2: The nameserver entries are located in the resolv.conf file. Technically this is where new DNS servers can be inserted. However, this file is managed by the system and gets overwritten regularly. To prevent these rewrites from happening, you must install the resolvconf program. Otherwise, the system will continue being updated as usual:

```bash
sudo apt update

sudo apt -y install resolvconf

sudo apt update
```
* Step 3: Check if the program has already started:
The status of the program should be displayed as “active”. If this is not the case, you can activate the service with the following commands:

```bash
systemctl start resolvconf.service

systemctl enable resolvconf.service

systemctl status resolvconf.service
```
# UPDATE HERE
* Step 4: Next you’ll customize the head document of this service. First, open the file, for example, with the nano editor:

```bash
nano /etc/resolvconf/resolv.conf.d/head
```
Now, enter the DNS server(s) you want into this file. For example, many people like to use the public DNS servers offered by Google. To use them, you need to enter the following IP addresses:
```bash
# /etc/resolvconf/resolv.conf.d/head

# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
# 127.0.0.53 is the systemd-resolved stub resolver.
# run "resolvectl status" to see details about the actual nameservers.

nameserver 192.168.1.50
nameserver 192.168.1.1
nameserver 8.8.8.8
search intranet.com
```
Save and close the file.

* Step 5: Lastly, you just need to update the resolv.conf file. To do this, use the following command:
```bash
resolvconf --enable-updates
resolvconf -u
```
* Now when you open the resolv.conf file, these two services should be inserted:

## /etc/network/interfaces

On Ubuntu 16.04 and Debian Linux servers, you can edit the /etc/network/interfaces file:

```bash
sudo nano /etc/network/interfaces
```

```bash
iface eth0 inet static
  address 192.168.1.55
  netmask 255.255.255.0
  gateway 192.168.1.1
  dns-nameserver 192.168.1.50
  dns-nameserver 192.168.1.1
  dns-nameserver 8.8.8.8
  dns-search intranet.com
```

# See The Results Updated

```bash
nano /etc/resolv.conf
```

## Restart Named
```bash

systemctl start named

systemctl enable named

systemctl status named

```


# How to uninstall or remove resolvconf 
* You can uninstall or removes an installed resolvconf package itself 
```bash
$ sudo apt-get remove resolvconf 
```

* Uninstall resolvconf including dependent package
If you would like to remove resolvconf and it's dependent packages which are no longer needed from Ubuntu,
```bash
$ sudo apt-get remove --auto-remove resolvconf 
```
* Use Purging resolvconf
If you use with purge options to resolvconf package all the configuration and dependent packages will be removed.
```bash
$ sudo apt-get purge resolvconf 
```
* If you use purge options along with auto remove, will be removed everything regarding the package, It's really useful when you want to reinstall again.
```bash
$ sudo apt-get purge --auto-remove resolvconf 
```


