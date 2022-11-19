#!/usr/bin/bash
#
# NAME: checkdeps.sh
#
# AUTH: JLONG
#
# DATE: 2022-02-22
#
# EXEC: ./checkdeps.sh
#
# This script checks to see if required dependencies are installed and directory structures are created. 
#

PNAME=`ps -ocomm --no-header $PPID`
[[ ! $PNAME == "domrecon.sh" ]] && { echo -en "run: domrecon.sh example.com\n";exit 1; }

RECON_DIR=~/recon

echo -en "\nChecking dependencies... "
for name in assetfinder nuclei fff httprobe
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name needs to be installed. Use 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "OK" || { echo -en "\nInstall the above and rerun this script\n";exit 1; }

echo -en "\nChecking project directory... "
[[ -d $RECON_DIR ]] && echo "OK" || { mkdir $RECON_DIR;echo -en "\n${RECON_DIR} created.\n";}

exit 0
