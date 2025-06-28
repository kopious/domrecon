#!/bin/sh
#
# NAME: nmap-all.sh
# DATE: 2025-04-19
#
# EXEC: nmap-all.sh example.com
#
# Performs a quick port scan on all domains and outputs only open ports
#

DOM=$1
DOM_DIR=~/recon/$DOM
PORTS_OUT="$DOM_DIR/open_ports.txt"

[[ ! -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} does not exist.\n";exit 1; }

# Clean old output
> "$PORTS_OUT"

while read -r domain; do
    echo "[+] Scanning $domain" | anew "$PORTS_OUT"
    # -p : scan specific ports
    # --open : show only open ports
    # -T5 : aggressive timing
    # --min-rate=5000 : send packets no slower than 5000 per second
    # -n : no DNS resolution
    nmap -p 21,22,23,25,53,80,110,143,443,3306,3389,4502,4503,5432,5900,6379,7000,7001,7002,7777,8000,8080,8888,8443 --open -T5 --min-rate=5000 -n "$domain" | grep ^[0-9] | anew "$PORTS_OUT"
    echo "---" | anew "$PORTS_OUT"
done < "$DOM_DIR/domains.txt"

exit 0
