#!/bin/sh
#
# NAME: session-fuzz.sh
# DATE: 2025-04-19
#
# EXEC: session-fuzz.sh example.com
#
# Finds session cookies in header files and uses them for fuzzing with ffuf
#

DOM=$1
DOM_DIR=~/recon/$DOM
FUZZ_OUT="$DOM_DIR/session-fuzz.txt"

[[ ! -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} does not exist.\n";exit 1; }

# Clean old output
> "$FUZZ_OUT"

WORDLIST=~/git/SecLists/Discovery/Web-Content/quickhits.txt
[[ ! -f "$WORDLIST" ]] && { echo -en "\nWordlist not found: $WORDLIST\n";exit 1; }

# Check if ffuf is installed
command -v ffuf >/dev/null 2>&1 || { echo -en "\nffuf is required but not installed.\n";exit 1; }

# Common session cookie names
SESSION_COOKIES=(
    "PHPSESSID"
    "JSESSIONID"
    "ASPSESSIONID"
    "SESSIONID"
    "session"
    "_session"
    "sid"
)

# Function to extract cookie value
get_cookie_value() {
    local header_file=$1
    local cookie_name=$2
    grep -i "Set-Cookie:" "$header_file" | grep -i "$cookie_name" | head -n1 | sed -n "s/.*${cookie_name}=\([^;]*\).*/\1/p"
}

# Function to run ffuf with cookie
run_ffuf() {
    local url=$1
    local cookie_name=$2
    local cookie_value=$3
    echo "[+] Fuzzing $url with $cookie_name=$cookie_value" | anew "$FUZZ_OUT"
    ffuf -u "${url}/FUZZ" -w "$WORDLIST" -H "Cookie: ${cookie_name}=${cookie_value}" -fs 2985 -s -r | anew "$FUZZ_OUT"
    echo "---" | anew "$FUZZ_OUT"
}

# Find all subdirectories containing DOM in name
find "$DOM_DIR" -type d -name "*$DOM*" | while read -r subdir; do
    # Use the subdirectory name as domain
    domain=$(basename "$subdir")
    
    # Find all header files in this subdirectory
    find "$subdir" -type f -name "*.headers" | while read -r header_file; do
        # Try each session cookie name
        for cookie_name in "${SESSION_COOKIES[@]}"; do
            cookie_value=$(get_cookie_value "$header_file" "$cookie_name")
            if [[ ! -z "$cookie_value" ]]; then
                # Try both http and https
                run_ffuf "http://$domain" "$cookie_name" "$cookie_value"
                run_ffuf "https://$domain" "$cookie_name" "$cookie_value"
            fi
        done
    done
done

exit 0
