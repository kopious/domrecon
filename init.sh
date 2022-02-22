#!/usr/bin/bash
#
# NAME: init.sh
#
# AUTH: JLONG
#
# DATE: 2022-02-22
#
# EXEC: init.sh
#
# This script checks to see if required dependencies are installed and directory structures are created. 
#

RECON_DIR=~/recon

echo -n "Checking dependencies... "
for name in sublist3r
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name needs to be installed. Use 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "OK" || { echo -en "\nInstall the above and rerun this script\n";exit 1; }

echo -n "Checking project directory... "
[[ -d $RECON_DIR ]] && echo "OK" || { mkdir $RECON_DIR;echo -en "\n${RECON_DIR} created.\n";}

exit 0
