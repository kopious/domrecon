#!/usr/bin/bash
#
# NAME: nikto.sh
#
# AUTH: JLONG
#
# DATE: 2022-11-18
#
# EXEC: nikto.sh example.com
#	cat urls.txt | scan.sh -
#
# This script is designed to run on Kali Linux with kali-tools-top10 installed 
# for dependencies and requires init.sh from https://github.com/kopious/domrecon
# must have nikto https://github.com/sullo/nikto
# 
# nikto.sh outputs to ~/recon/<domain>/nikto.out 
# requires: <domain> as input from stdin
# requires: ~/recon/<domain>/urls.txt to exist
# outputs: ~/recon/<domain>/scan.out 
#

set -x

DOM=$1
DOM_DIR=~/recon/$DOM
DOM_FIL=$DOM_DIR/domains.txt
URL_FIL=$DOM_DIR/urls.txt
OUT_FIL=$DOM_DIR/nikto.out


echo "processing ${DOM}" >> $OUT_FIL

[[ ! -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} does not exist.\n";exit 1; }

while read -r line; 
do 
	perl ~/git/nikto/program/nikto.pl -h $line | anew $OUT_FIL 
done < $DOM_FIL

exit 0
