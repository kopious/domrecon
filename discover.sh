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
[[ $# -ne 1 ]] && { echo -en "Usage: $0 example.com\n";exit 1; }

DOM=$1
DOM_DIR=~/recon/$DOM
DOM_FIL=$DOM_DIR/domains.txt
URL_FIL=$DOM_DIR/urls.txt

[[ -d $DOM_DIR ]] && { echo -en "${DOM_DIR} already exists.\n";exit 1; }

./init.sh
status=$?

[[ $status -ne 0 ]] && { echo -en "Failed to init\n";exit 1; }


mkdir $DOM_DIR

sublist3r -v -d $1 -o $DOM_FIL

cat $DOM_FIL |awk '{print "https://"$1}' > $URL_FIL


echo "Done"
exit 0
