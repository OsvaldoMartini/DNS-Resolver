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