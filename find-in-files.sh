#!/bin/sh
#
# NAME: find-in-files.sh
#
# AUTH: JLONG
#
# DATE: 2024-8-27
#
# EXEC: find-in-files.sh /tmp/list-of-names.txt ~/git/report/content
#
# DEPS: anew - https://github.com/tomnomnom/anew
#
# This script searches all files in a given path to find matching strings in a list provided.
#   
#

STRINGS=$1
SEARCH_PATH=$2
OUTPUT=found-matches.txt 

SEARCH_COUNT=`wc -l $STRINGS`
echo -en "Number of input strings ${SEARCH_COUNT}"

while read -r line; 
do 
	find $SEARCH_PATH -type f -exec grep -ios "$line" {} \; | tr '[:upper:]' '[:lower:]' | anew $OUTPUT
done < $STRINGS

FOUND_COUNT=`wc -l $OUTPUT`
echo -en "Found strings ${FOUND_COUNT}"

