#!/bin/sh
#
# NAME: discover.sh
#
# AUTH: JLONG
#
# DATE: 2022-02-22
#
# EXEC: discover.sh example.com
#
# This script is designed to run on Kali Linux with kali-tools-top10 installed 
# for dependencies and requires init.sh from https://github.com/kopious/domrecon
# 
# discover.sh outputs to ~/recon/<domain> two files: domain.txt and urls.txt
# to be used in further analysis steps.
#

set -x

DOM=$1
DOM_DIR=~/recon/$DOM
DOM_FIL=$DOM_DIR/domains.txt
URL_FIL=$DOM_DIR/urls.txt

[[ -d ~/recon ]] || mkdir ~/recon 

[[ -d $DOM_DIR ]] || mkdir $DOM_DIR

echo $DOM | anew $DOM_FIL

assetfinder $1 | anew $DOM_FIL 

cat $DOM_FIL | httprobe -s -p https:443 | grep "$DOM" | anew $URL_FIL

cat $URL_FIL | fff -s 200 -o $DOM_DIR - &> /dev/null


exit 0
