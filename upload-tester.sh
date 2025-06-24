#!/bin/sh
# Tests file upload restrictions and uploads allowed files
# Usage: upload-tester.sh example.com
DOM=$1
DOM_DIR=~/recon/$DOM
COOKIE_FILE="$DOM_DIR/cookie.txt"
UPLOAD_URL="http://$DOM/upload.php"
RESULTS_FILE="$DOM_DIR/upload-results.txt"

[[ ! -d $DOM_DIR ]] && { echo "${DOM_DIR} does not exist."; exit 1; }
[[ ! -f $COOKIE_FILE ]] && { echo "Cookie file not found. Run register-login.sh first."; exit 1; }

echo "Testing file uploads..." > "$RESULTS_FILE"

for type in jpg png txt gif; do
    echo "Testing .$type..." | tee -a "$RESULTS_FILE"
    echo "testfile" > "testfile.$type"
    curl -s -b "$COOKIE_FILE" -F "file=@testfile.$type" "$UPLOAD_URL" | tee -a "$RESULTS_FILE"
    rm -f "testfile.$type"
done
