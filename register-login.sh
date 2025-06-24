#!/bin/sh
# Registers and logs in a user, saving the session cookie.
# Usage: register-login.sh example.com
DOM=$1
DOM_DIR=~/recon/$DOM
COOKIE_FILE="$DOM_DIR/cookie.txt"

USER="ctfuser$(date +%s)"
PASS="ctfpass123!"

[[ ! -d $DOM_DIR ]] && { echo "${DOM_DIR} does not exist."; exit 1; }

# Register
curl -s -c "$COOKIE_FILE" -d "username=$USER&password=$PASS" "http://$DOM/register.php" > "$DOM_DIR/register-response.txt"

# Login
curl -s -b "$COOKIE_FILE" -c "$COOKIE_FILE" -d "username=$USER&password=$PASS" "http://$DOM/login.php" > "$DOM_DIR/login-response.txt"

echo "$USER:$PASS" > "$DOM_DIR/registered-user.txt"
echo "Registered and logged in as $USER"
