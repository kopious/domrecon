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
    # -p- : scan all ports
    # --open : show only open ports
    # -T4 : aggressive timing
    # --min-rate=1000 : send packets no slower than 1000 per second
    # -n : no DNS resolution
    nmap -p- --open -T4 --min-rate=1000 -n "$domain" | grep ^[0-9] | anew "$PORTS_OUT"
    echo "---" | anew "$PORTS_OUT"
done < "$DOM_DIR/domains.txt"

exit 0
