$TTL    1d ; default expiration time (in seconds) of all RRs without their own TTL value
@       IN      SOA     ns1.shifthunter.com. root.shifthunter.com. (
                  3      ; Serial
                  1d     ; Refresh
                  1h     ; Retry
                  1w     ; Expire
                  1h )   ; Negative Cache TTL

; name servers - NS records
     IN      NS      ns1.shifthunter.com.

; name servers - A records
ns1.shifthunter.com.             IN      A      172.24.0.2

service1.shifthunter.com.        IN      A      172.24.0.3
service2.shifthunter.com.        IN      A      172.24.0.4