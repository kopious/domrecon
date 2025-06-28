#!/bin/sh
#
# NAME: dirsearch.sh
# DATE: 2025-04-19
#
# EXEC: dirsearch.sh example.com
#
# Performs directory enumeration for each domain using SecLists wordlist
# Requires: dirsearch, SecLists (https://github.com/danielmiessler/SecLists)
#

DOM=$1
DOM_DIR=~/recon/$DOM
DIRSEARCH_OUT="$DOM_DIR/dirsearch.txt"
PORTS_FILE="$DOM_DIR/open_ports.txt"

[[ ! -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} does not exist.\n";exit 1; }
[[ ! -f "$PORTS_FILE" ]] && { echo -en "\n${PORTS_FILE} does not exist. Run nmap-all.sh first.\n";exit 1; }

# Clean old output
> "$DIRSEARCH_OUT"

#WORDLIST=~/git/SecLists/Discovery/Web-Content/directory-list-2.3-small.txt
WORDLIST=~/git/SecLists/Discovery/Web-Content/quickhits.txt
[[ ! -f "$WORDLIST" ]] && { echo -en "\nWordlist not found: $WORDLIST\n";exit 1; }

# Create filtered wordlist without comments
FILTERED_WORDLIST="$DOM_DIR/filtered-wordlist.txt"
grep -v '^#' "$WORDLIST" > "$FILTERED_WORDLIST"

# Function to run dirsearch on a specific URL
run_dirsearch() {
    local url=$1
    echo "[+] Directory search for: $url" | anew "$DIRSEARCH_OUT"
    dirsearch -200only -url "$url" -wordlist "$FILTERED_WORDLIST" | anew "$DIRSEARCH_OUT"
    echo "---" | anew "$DIRSEARCH_OUT"
}

# Process open_ports.txt
current_domain=""
while IFS= read -r line; do
    # Check if this is a domain header line
    if [[ "$line" == "[+] Scanning"* ]]; then
        current_domain=$(echo "$line" | cut -d' ' -f3)
        continue
    fi
    
    # Skip if not a port line or separator
    if [[ ! "$line" =~ ^[0-9] ]] && [[ "$line" != "---" ]]; then
        continue
    fi
    
    # Process port line
    if [[ "$line" =~ ^[0-9] ]]; then
        port=$(echo "$line" | cut -d'/' -f1)
        service=$(echo "$line" | tr -s ' ' | cut -d' ' -f3)
        
        # Check if HTTP/HTTPS service
        case "$service" in
            *http*)
                if [[ "$service" == *ssl* ]] || [[ "$service" == *https* ]] || [[ "$port" == "443" ]]; then
                    run_dirsearch "https://${current_domain}:${port}"
                else
                    run_dirsearch "http://${current_domain}:${port}"
                fi
                ;;
        esac
    fi
done < "$PORTS_FILE"

exit 0
