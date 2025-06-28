#!/bin/bash
#
# EXEC: analyze.sh <domain>
#
# Analyze fetched root assets for:
#   1. Content fingerprinting (WhatWeb)
#   2. Vulnerability discovery (secrets, outdated JS)
#   3. Asset enumeration (links, subdomains)
#
# Output files:
#   whatweb.txt, secrets.txt, vuln_libs.txt, links.txt, subdomains.txt
#   (all saved to ~/recon/<domain>/analysis/)
#

set -x

if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOM=$1
DOM_DIR=~/recon/$DOM
ANALYSIS_DIR=$DOM_DIR/analysis
mkdir -p "$ANALYSIS_DIR"

SECRETS_OUT="$ANALYSIS_DIR/secrets.txt"
VULN_LIBS_OUT="$ANALYSIS_DIR/vuln_libs.txt"
LINKS_OUT="$ANALYSIS_DIR/links.txt"
SUBDOMAINS_OUT="$ANALYSIS_DIR/subdomains.txt"
HEADER_ISSUES_OUT="$ANALYSIS_DIR/header_issues.txt"

# Clean old outputs
> "$SECRETS_OUT"
> "$VULN_LIBS_OUT"
> "$LINKS_OUT"
> "$SUBDOMAINS_OUT"
> "$HEADER_ISSUES_OUT"

# Helper regexes and lists
SECRET_REGEXES='AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z\-\_]{35}|[sS]ecret|[tT]oken|[aA]pi[\_\-]key|sk_live_[0-9a-zA-Z]{24}|eyJ[A-Za-z0-9\-\_]{20,}\.[A-Za-z0-9\-\_]{20,}\.[A-Za-z0-9\-\_]{20,}'
VULN_LIBS_LIST='jquery|bootstrap|angular|react|vue|ember|dojo|backbone|knockout|lodash|underscore'

# Security headers to check for
SECURITY_HEADERS=(
    '< Strict-Transport-Security'
    '< Content-Security-Policy'
    '< X-Frame-Options'
    '< X-Content-Type-Options'
    '< X-XSS-Protection'
    '< Referrer-Policy'
    '< Permissions-Policy'
    '< Cross-Origin-Opener-Policy'
    '< Cross-Origin-Embedder-Policy'
    '< Cross-Origin-Resource-Policy'
)

# Function to analyze headers
analyze_headers() {
    local HEADERFILE=$1
    local URL=$2
    
    echo "[+] Analyzing headers for: $URL" | anew "$HEADER_ISSUES_OUT"
    
    # Check for server information disclosure
    grep -i '^< Server:' "$HEADERFILE" | anew "$HEADER_ISSUES_OUT" || true
    grep -i '^< X-Powered-By:' "$HEADERFILE" | anew "$HEADER_ISSUES_OUT" || true
    
    # Check for missing security headers
    for header in "${SECURITY_HEADERS[@]}"; do
        if ! grep -qi "^${header}:" "$HEADERFILE"; then
            echo "[-] Missing security header: $header" | anew "$HEADER_ISSUES_OUT"
        fi
    done
    
    # Check cookie security
    grep -i '^< Set-Cookie:' "$HEADERFILE" | while read -r cookie; do
        if ! echo "$cookie" | grep -qi 'secure'; then
            echo "[-] Cookie without Secure flag: $cookie" | anew "$HEADER_ISSUES_OUT"
        fi
        if ! echo "$cookie" | grep -qi 'httponly'; then
            echo "[-] Cookie without HttpOnly flag: $cookie" | anew "$HEADER_ISSUES_OUT"
        fi
        if ! echo "$cookie" | grep -qi 'samesite'; then
            echo "[-] Cookie without SameSite attribute: $cookie" | anew "$HEADER_ISSUES_OUT"
        fi
    done
    
    # Check CORS headers
    grep -i '^< Access-Control-Allow-' "$HEADERFILE" | while read -r cors; do
        if echo "$cors" | grep -qi 'origin:.*\*'; then
            echo "[-] Overly permissive CORS: $cors" | anew "$HEADER_ISSUES_OUT"
        fi
    done
    
    echo "---" | anew "$HEADER_ISSUES_OUT"
}

# Find all .body files
find "$DOM_DIR" -type f -name '*.body' | while read BODYFILE; do
    # Get corresponding header file
    HEADERFILE="${BODYFILE%.body}.headers"
    # Derive URL from path
    RELPATH="${BODYFILE#$DOM_DIR/}"
    SUBDOM="${RELPATH%%/*}"
    URL="https://$SUBDOM/"

    # Vulnerability Discovery: Secrets
    cat "$BODYFILE" | grep -Eio -A 2 -B 2 "$SECRET_REGEXES" | while read -r match; do
        if [[ ! -z "$match" ]]; then
            echo "[URL: $URL]\nContext: $match\n---" | anew "$SECRETS_OUT" || true
        fi
    done

    # Vulnerable JS libraries
    cat "$BODYFILE" | grep -Eoi "<script[^>]+src=['\"][^'\"]+['\"]" | \
        grep -E "$VULN_LIBS_LIST" | \
        awk -F"src=" '{print $2}' | anew "$VULN_LIBS_OUT" || true

    # Asset Enumeration: Links
    cat "$BODYFILE" | grep -Eoi "href=['\"][^'\"]+['\"]" | \
        awk -F"href=" '{print $2}' | anew "$LINKS_OUT" || true
    cat "$BODYFILE" | grep -Eoi "src=['\"][^'\"]+['\"]" | \
        awk -F"src=" '{print $2}' | anew "$LINKS_OUT" || true

    # Asset Enumeration: Subdomains
    cat "$BODYFILE" | grep -Eo "[a-zA-Z0-9._-]+\\.$DOM" | anew "$SUBDOMAINS_OUT" || true

    # Analyze headers if header file exists
    if [[ -f "$HEADERFILE" ]]; then
        analyze_headers "$HEADERFILE" "$URL"
    fi

done

echo "Analysis complete. Results saved in $ANALYSIS_DIR."
exit 0
