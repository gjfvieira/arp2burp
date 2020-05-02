# arp2burp
From ARP Spoofing to HTTP Proxy - HTTP Traffic intercept 

## How to Install

1. Git clone using $ git clone <git>
2. $ chmode +x arp2burp.sh
3. $ ./arp2burp.sh

## Configurations / Requirements

1. Burp Suite or MITM Proxy
2. If running inside a VM make sure it's bridged and with promiscous mode enabled
3. arpspoof is required - in Ubuntu or Debian use `apt-get install dsniff`

## TODO

1. Default values
2. Option to manually add other Ports to iptables rules (current 80/443)
3. No HTTP Proxy set - Pure ARP Spoofing
4. Config file with default values
5. Automatically set selected interface in either monitor mode or promiscous mode
