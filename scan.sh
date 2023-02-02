#!/usr/bin/bash
#
# NAME: scan.sh
#
# AUTH: JLONG
#
# DATE: 2022-06-27
#
# EXEC: scan.sh example.com
#	cat urls.txt | scan.sh -
#
# This script is designed to run on Kali Linux with kali-tools-top10 installed 
# for dependencies and requires init.sh from https://github.com/kopious/domrecon
# 
# scan.sh outputs to ~/recon/<domain>/scan.out 
# requires: <domain> as input from stdin
# requires: ~/recon/<domain>/urls.txt to exist
# outputs: ~/recon/<domain>/scan.out 
#

set -x

DOM=$1
DOM_DIR=~/recon/$DOM
DOM_FIL=$DOM_DIR/domains.txt
URL_FIL=$DOM_DIR/urls.txt
OUT_FIL=$DOM_DIR/scan.out
TMP_FIL=$DOM_DIR/http.tmp

echo "processing ${DOM}" >> $OUT_FIL

[[ ! -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} does not exist.\n";exit 1; }
[[ ! -f $URL_FIL ]] && { echo -en "\n${URL_FIL} does not exist.\n" >> $OUT_FIL;exit 1; }

cat $DOM_FIL | grep $DOM | httprobe | anew $TMP_FIL

nuclei -l $TMP_FIL -t ~/nuclei-templates -s critical,high,medium | anew $OUT_FIL

rm $TMP_FIL

exit 0
