$TTL    604800
@       IN      SOA     ns1.shifthunter.com. admin.shifthunter.com. (
                              5         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;

; Name servers
shifthunter.com.    IN      NS      ns1.shifthunter.com.
shifthunter.com.    IN      NS      ns2.shifthunter.com.

; A records for name servers
ns1             IN      A       192.168.1.65
ns2             IN      A       192.168.1.66

; Other A records
@               IN      A       192.168.1.63
www             IN      A       192.168.1.63
