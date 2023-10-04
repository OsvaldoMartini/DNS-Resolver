$TTL    604800
@       IN      SOA     ns1.shifthunter.com. admin.shifthunter.com. (
                  7     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL
;
; name servers - NS records
     IN      NS      ns1.shifthunter.com.
     IN      NS      ns2.shifthunter.com.

; name servers - A records
ns1.shifthunter.com.          IN      A       192.168.1.65
ns2.shifthunter.com.          IN      A       192.168.1.66

; 10.128.0.0/16 - A records
;host1.shifthunter.com.        IN      A      10.128.100.101
;host2.shifthunter.com.        IN      A      10.128.200.102

; 192.168.0/16 - A records
amazonlinux.shifthunter.com.   IN      A      192.168.1.63
vmlinux1.shifthunter.com.      IN      A      192.168.1.57