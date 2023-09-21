$TTL    1d ; default expiration time (in seconds) of all RRs without their own TTL value
@       IN      SOA     ns1.instar-net.io. root.instar-net.io. (
                  3      ; Serial
                  1d     ; Refresh
                  1h     ; Retry
                  1w     ; Expire
                  1h )   ; Negative Cache TTL

; name servers - NS records
     IN      NS      ns1.instar-net.io.

; name servers - A records
ns1.instar-net.io.             IN      A      172.24.0.2

service1.instar-net.io.        IN      A      172.24.0.3
service2.instar-net.io.        IN      A      172.24.0.4