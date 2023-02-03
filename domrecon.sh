#!/bin/sh
#
# NAME: domrecon.sh
#
# AUTH: JLONG
#
# DATE: 2022-02-22
#
# EXEC: domrecon.sh example.com
#

read -r -d '' header <<'EOF'
________                __________
\______ \   ____   _____\______   \ ____   ____  ____   ____
 |    |  \ /  _ \ /     \|       _// __ \_/ ___\/  _ \ /    \
 |    `   (  <_> )  Y Y  \    |   \  ___/\  \__(  <_> )   |  \
/_______  /\____/|__|_|  /____|_  /\___  >\___  >____/|___|  /
        \/             \/       \/     \/     \/           \/
EOF

printf "%s\n" "$header"

[[ $# -ne 1 ]] && { echo -en "Usage: $0 example.com\n";exit 1; }

DOM=$1

echo -ne "Running reconnaissance on ${DOM}... "

for script in checkdeps.sh discover.sh scan.sh
do

  echo -ne "\nScript: ${script}..."

  ./$script $DOM
  [[ $? -eq 0 ]] && echo -en "OK" || { echo -en "failed.";fails=1; }
done

[[ $fails -ne 1 ]] || { echo -en "\nResolve errors listed above and rerun this script\n";exit 1; }

exit 0
