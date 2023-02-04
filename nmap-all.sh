#!/bin/sh
#
#


INPUT=~/recon/$1/domains.txt
 
while read domain
do
	nmap -sV $domain |tee ~/recon/$1/nmap_results.txt
 
done < $INPUT


