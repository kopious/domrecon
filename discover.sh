#!/usr/bin/bash
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

PNAME=`ps -ocomm --no-header $PPID`
[[ ! $PNAME == "domrecon.sh" ]] && { echo -en "\nrun: domrecon.sh example.com\n";exit 1; }

DOM=$1
DOM_DIR=~/recon/$DOM
DOM_FIL=$DOM_DIR/domains.txt
URL_FIL=$DOM_DIR/urls.txt

[[ -d $DOM_DIR ]] && { echo -en "\n${DOM_DIR} already exists.\n";exit 1; }

mkdir $DOM_DIR

assetfinder $1 |anew $DOM_FIL 

cat $DOM_FIL |awk '{print "https://"$1}' > $URL_FIL 

cat $URL_FIL | fff -S -o $DOM_DIR - &> /dev/null


exit 0
