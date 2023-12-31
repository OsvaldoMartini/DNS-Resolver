All steps will be performed as root user
===========================================
# BIND configuration

## VirtualBox Guest Additions

 VBoxGuestAdditions  on DDbian
[VBoxGuestAdditions Debian](https://linuxize.com/post/how-to-install-virtualbox-guest-additions-on-debian-10/)
Open the Debian guest terminal, create a new directory , and mount the ISO file:

```bash
sudo mkdir -p /mnt/cdrom

sudo mount /dev/cdrom /mnt/cdrom
```
Navigate to the directory and execute the VBoxLinuxAdditions.run script to install the Guest Additions:
```bash
cd /mnt/cdrom

sudo sh ./VBoxLinuxAdditions.run --nox11
```
The --nox11 option tells the installer not to spawn an xterm window.
The output will look like below:
```bash
Verifying archive integrity... All good.
Uncompressing VirtualBox 6.0.16 Guest Additions for Linux........
...
...
VirtualBox Guest Additions: Starting.
```
Reboot the Debian guest for changes to take effect:
```bash
sudo shutdown -r now
```
Once the virtual machine is booted, log into it and verify that the installation was successful and the kernel module is loaded using the lsmod command:
```bash
lsmod | grep vboxguest

# Expected:
vboxguest             348160  2 vboxsf
```

```bash
 Folder
  shared/usr/share/virtualbox VBoxGuestAdditions.iso


	On C:/Program Files/Oracle/VirtualBox/VBoxGuestAdditions.iso

	Create the Shared Folder to above 
	General -> Advance Bidirectional for both options
	
	apt-get install virtualbox-guest-additions-iso
```

## 1) set a domain name in the 
```bash
	/etc/sysconfig/network-scripts/ifcfg-enp0s3
```


* Example Name: shifthunter.com, mydomain.com, myhome.net etc
* Select the proper ifcfg- <'NIC Name'> file based on the name of the network interface in your host

## 2) modify /etc/hosts with FQN (Fully Qualified Name) such as adminsvr.shifthunter.com, myserver.myhome.net etc adding the domain then restart the 
```bash
network using the command below:

service network restart
```

## 3) Install the BIND related packages and libraries
```bash
	yum install bind-libs bind bind-utils
```

## 4) Modify the file /etc/named.conf to add information relevant to us

You have to careful while editing this file as a little mistake in like a missing comma, a colon or a dot may end up in not being able to bring up the named service
```bash

	//
	// named.conf
	//
	// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
	// server as a caching only nameserver (as a localhost DNS resolver only).
	//
	// See /usr/share/doc/bind*/sample/ for example named configuration files.
	//
	// See the BIND Administrator's Reference Manual (ARM) for details about the
	// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

	options {
		listen-on port 53 { 127.0.0.1; 192.168.1.67; };
		listen-on-v6 port 53 { ::1; };
		directory       "/var/named";
		dump-file       "/var/named/data/cache_dump.db";
		statistics-file "/var/named/data/named_stats.txt";
		memstatistics-file "/var/named/data/named_mem_stats.txt";
		recursing-file  "/var/named/data/named.recursing";
		secroots-file   "/var/named/data/named.secroots";
		allow-query     { localhost; 192.168.1.0/24; };

		/*
			- If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
			- If you are building a RECURSIVE (caching) DNS server, you need to enable
			recursion.
			- If your recursive DNS server has a public IP address, you MUST enable access
			control to limit queries to your legitimate users. Failing to do so will
			cause your server to become part of large scale DNS amplification
			attacks. Implementing BCP38 within your network would greatly
			reduce such attack surface
		*/
		recursion yes;

		dnssec-enable yes;
		dnssec-validation yes;

		/* Path to ISC DLV key */
		bindkeys-file "/etc/named.root.key";

		managed-keys-directory "/var/named/dynamic";

		pid-file "/run/named/named.pid";
		session-keyfile "/run/named/session.key";
	};

	logging {
		channel default_debug {
			file "data/named.run";
			severity dynamic;
		};
	};

	zone "." IN {
		type hint;
		file "named.ca";
	};
	zone "shifthunter.com" IN {
		type master;
			file "/var/named/shifthunter.com.zone";
			allow-update { none; };
		};
	zone "1.168.192.in-addr.arpa" IN {
			type master;
			file "/var/named/1.168.192.in-addr.arpa.zone";
			allow-update { none; };
	};

	include "/etc/named.rfc1912.zones";
	include "/etc/named.root.key";
```


## 4) Modify/Create the 3 Zone files below after changing directory to /var/named and add the contents as mentioned:
```bash
[root@adminsvr named]# cd /var/named/
[root@adminsvr named]# pwd
/var/named

[root@adminsvr named]# ls -lrt

-rw-r-----. 1 root  named  153 Sep  7 18:28 named.localhost
-rw-r--r--. 1 root  root   292 Sep  7 19:13 1.168.192.in-addr.arpa.zone
-rw-r--r--. 1 root  root   391 Sep  7 20:16 shifthunter.com.zone
```

```bash
named.localhost content
========================
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
```

```bash
shifthunter.com.zone content
========================

$TTL    1d
@  IN    SOA   adminsvr.shifthunter.com. root.shifthunter.com. (
    100        ; se = serial number
    8h         ; ref = refresh
    5m         ; ret = update retry
    3w         ; ex = expiry
    3h         ; min = minimum
    )

    IN    NS    adminsvr.shifthunter.com.

; DNS server
adminsvr  IN    A    192.168.1.67


;Other VMs
vmlinux1  IN    A    192.168.1.57
```

```bash
1.168.192.in-addr.arpa.zone content
========================

$TTL    1d
@   IN    SOA   adminsvr.shifthunter.com. root.shifthunter.com. (
    100        ; se = serial number
    8h         ; ref = refresh
    5m         ; ret = update retry
    3w         ; ex = expiry
    3h         ; min = minimum
    )

    IN    NS    adminsvr.shifthunter.com.

57     IN PTR  vmlinux1.shifthunter.com.
67     IN PTR  adminsvr.shifthunter.com.
```
```bash
[root@adminsvr named]#
```

## 5) Start named service
```bash
service named start
```

## 6) Make sure the service "named" starts with server reboot
```bash
chkconfig named on
```
## 7) Add the new DNS1 for the DNS servers's IP address and change any old DNS1 to DNS2 in /etc/sysconfig/network-scripts/ifcfg-enp0s3
```bash
Select the proper ifcfg-<NIC Name> file based on the name of the network interface in your host

DNS1=192.168.1.67
DNS2=192.168.1.1
```
## 8) Restart network services:
```bash
service network restart
```
## 9) Validate /etc/resolv.conf. Output should be something like 
```bash
	# cat /etc/resolv.conf 
	nameserver 192.168.1.67
	nameserver 192.168.1.1
	search oraexpert.log
```

## 10) Restart named service and test name resolution with nslookup
```bash
service named stop
service named start
 ```
# Test:
```bash
nslookup adminsvr
nslookup vmlinux1


telnet 192.168.1.67 53

telnet 192.168.1.57 53

traceroute 192.168.1.67 -p 53

traceroute 192.168.1.57 -p 53
```

## getenforce  Turning off **SELINUX=disabled**
* for Boths or ***all*** VMs 
```bash
 usage:  setenforce [ Enforcing | Permissive | 1 | 0 ]
 setenforce 1 # Enforcing
 setenforce 0 # Permissive

	nano /etc/selinux/config
		...
	SELINUX=enforcing   
	to
	SELINUX=disabled

 # It must Shutdhown
	shutdown -r 0
```

## Cmds Summary
```bash
	# Its checks the named files
	named-checkconfig

	named-checkzone adminsvr /var/named/shifthunter.com.zone

	named-checkzone adminsvr /var/named/1.168.192.in-addr.arpa.zone

	chkconfig named on

	service network stop

	systemctl named stop
	systemctl named start
	systemctl named status

	chkconfig named on

	// Depends on Which Linux Version
	systemctl restart systemd-networkd	
```

## Firewall
```bash	service firewalld stop

	systemctl firewalld start

  # Issue the following command to open port 1191 for TCP traffic.
	firewall-cmd --add-port 53/tcp		

	# Issue the following command to open port 1191 for TCP traffic after reboot. Use this command to make changes persistent.
	firewall-cmd --permanent --add-port 53/tcp
	
	# Issue the following command to open a range a range of ports.
	firewall-cmd --permanent --add-port 60000-61000/tcp

  firewall-cmd --add-port 53/tcp --add-port 53/udp --permanent 

	firewall-cmd --reload	
	
	firewall-cmd --list-ports

	nano /etc/resolv.conf

```

## CH Root is is enabled
```bash

# To Enalbe it
/usr/libexec/setup-named-chroot.sh /var/named/chroot on

mount | grep chroot



  # CREATE THE DIRECTORY IF IN CASE DOESN'T EXIST
mkdir /var/named/chroot/usr/lib64/named
 
AND TRY TO CREATE  IT AGAIN

/usr/libexec/setup-named-chroot.sh /var/named/chroot on

 mount | grep chroot

 systemctl status named-chroot

 systemctl start named-chroot

 systemctl enable named-chroot.service


 ss -anl | grep ":53"

 netstat -antp

```
## Windows  Configs

![Network](DNS-Properties-On-Windodws-1.png)
## DNS Name
![Network](DNS-Properties-On-Windodws-2.png)

## Windows Hostname
```cmd
	hostname 

	c:> WIN-BK6RHQNLS4K
```

## Include the Hostname on  
* 1) /var/named/shifthunter.com.zone

* 2) /var/named/1.168.192.in-addr.arpa

```bash

# Lookup
# /var/named/shifthunter.com.zone
...
WIN-BK6RHQNLS4K  IN     A    192.168.1.47

# Reverse lookup
# /var/named/1.168.192.in-addr.arpa
...
47     IN PTR  WIN-BK6RHQNLS4K.shifthunter.com

service named stop
service named start
service named status

systemctl network restart
or
systemctl restart named-chroot
```

## Permission to a file
```bash	

	chwn -R apache:apache index.html
	chmod -R 775 index.html

	# Create the confi file for each WebPage
  nano /etc/httpd/conf.d/firt_web.conf


For example:

chmod 777 foldername will give read, write, and execute permissions for everyone.

chmod 700 foldername will give read, write, and execute permissions for the user only.

chmod 327 foldername will give write and execute (3) permission for the user, w (2) for the group, and read, write, and execute for the users.

```

